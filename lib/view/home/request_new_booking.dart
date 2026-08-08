import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/provider/home_provider.dart';
import 'package:sq_notification/view/home/add_booking.dart';
import 'package:sq_notification/view/home/form_page.dart';

const Map<String, IconData> _industryIcons = {
  "healthcare": Icons.local_hospital_outlined,
  "education": Icons.school_outlined,
  "government": Icons.account_balance_outlined,
  "business": Icons.business_center_outlined,
};

IconData _iconForIndustry(String industry) {
  return _industryIcons[industry.toLowerCase()] ?? Icons.build_outlined;
}

class RequestNewBooking extends StatefulWidget {
  const RequestNewBooking({super.key});

  @override
  State<RequestNewBooking> createState() => _RequestNewBookingState();
}

class _RequestNewBookingState extends State<RequestNewBooking> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.getIndustriesList();
    });
  }

  int _currentStep(HomeProvider homeProvider) {
    if (homeProvider.selectedIndusty.isEmpty) return 0;
    if (homeProvider.selectedCompanies.isEmpty) return 1;
    return 2;
  }

  void _continue(BuildContext context, HomeProvider provider) {
    if (provider.selectedUnit.isEmpty) {
      Fluttertoast.showToast(msg: "Please choose a service provider");
      return;
    }
    if (provider.serviceType.toLowerCase() == "Appointment".toLowerCase()) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddBooking()));
    } else if (provider.serviceType.toLowerCase() == "Data Capture".toLowerCase()) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => FormPage()));
    } else {
      Fluttertoast.showToast(msg: "This service provider has no bookable service type");
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: true);
    final step = _currentStep(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Service"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepIndicator(step: step),
            const SizedBox(height: 16),
            Expanded(
              child: step == 0
                  ? _IndustryStep(homeProvider: homeProvider)
                  : step == 1
                      ? _OrganisationStep(homeProvider: homeProvider)
                      : _ProviderStep(homeProvider: homeProvider),
            ),
            if (step == 2 && homeProvider.selectedUnit.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _continue(context, homeProvider),
                  child: const Text("Continue"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;

  const _StepIndicator({required this.step});

  Widget _dot(BuildContext context, int index, String label) {
    final active = index <= step;
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(context, 0, "Industry"),
        _dot(context, 1, "Organisation"),
        _dot(context, 2, "Service Provider"),
      ],
    );
  }
}

class _IndustryStep extends StatelessWidget {
  final HomeProvider homeProvider;

  const _IndustryStep({required this.homeProvider});

  @override
  Widget build(BuildContext context) {
    if (homeProvider.industryList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: homeProvider.industryList.map((industry) {
        return Card(
          child: InkWell(
            onTap: () => homeProvider.setSelectedList(industry),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_iconForIndustry(industry), size: 32),
                  const SizedBox(height: 8),
                  Text(industry, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _OrganisationStep extends StatefulWidget {
  final HomeProvider homeProvider;

  const _OrganisationStep({required this.homeProvider});

  @override
  State<_OrganisationStep> createState() => _OrganisationStepState();
}

class _OrganisationStepState extends State<_OrganisationStep> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final homeProvider = widget.homeProvider;
    final filtered = _query.isEmpty
        ? homeProvider.companiesList
        : homeProvider.companiesList
            .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => homeProvider.setSelectedList(""),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: Text("Industry: ${homeProvider.selectedIndusty}"),
        ),
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: "Search organisation by name",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: homeProvider.companiesList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final company = filtered[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.apartment_outlined),
                        title: Text(company),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => homeProvider.setCompaniesList(company),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ProviderStep extends StatelessWidget {
  final HomeProvider homeProvider;

  const _ProviderStep({required this.homeProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => homeProvider.setCompaniesList(""),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: Text("Organisation: ${homeProvider.selectedCompanies}"),
        ),
        Expanded(
          child: homeProvider.unitList.isEmpty
              ? const Center(child: Text("No service providers found"))
              : ListView.builder(
                  itemCount: homeProvider.unitList.length,
                  itemBuilder: (context, index) {
                    final unit = homeProvider.unitList[index];
                    final selected = homeProvider.selectedUnit == unit;
                    return Card(
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: const Icon(Icons.storefront_outlined),
                        title: Text(unit),
                        trailing: selected ? const Icon(Icons.check_circle) : null,
                        onTap: () => homeProvider.setUnitList(unit),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
