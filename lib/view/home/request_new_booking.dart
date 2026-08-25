import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sq_notification/constant/app_colors.dart';
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

  // Most organisations only have a single service provider, so the "Service Provider" step
  // would just be a one-item list to tap through -- skip straight to the booking page in that
  // case, only falling back to showing the step when there's an actual choice to make.
  Future<void> _selectOrganisation(BuildContext context, HomeProvider provider, String company) async {
    await provider.setCompaniesList(company);
    if (!context.mounted) return;
    if (provider.unitList.length == 1) {
      provider.setUnitList(provider.unitList.first);
      _continue(context, provider);
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
                      ? _OrganisationStep(
                          homeProvider: homeProvider,
                          onSelectOrganisation: (company) =>
                              _selectOrganisation(context, homeProvider, company),
                        )
                      : _ProviderStep(
                          homeProvider: homeProvider,
                          onSelectProvider: (unit) {
                            homeProvider.setUnitList(unit);
                            _continue(context, homeProvider);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  static const List<String> _labels = ["Industry", "Organisation", "Service Provider"];

  const _StepIndicator({required this.step});

  Widget _line(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? kSmartQGreen : Colors.grey.shade300,
      ),
    );
  }

  // Each unit is its own circle flanked by a left/right half-connector, so adjacent units' halves
  // join into one continuous line running through the circles' vertical center -- putting the
  // connector in a second, separate Row (below or between columns) can't align with the circle's
  // center once labels of varying width are involved, this keeps the line and the circles in the
  // same Row so they're trivially aligned.
  Widget _unit(BuildContext context, int index) {
    final active = index <= step;
    return Expanded(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              index == 0 ? const Spacer() : _line(step >= index),
              CircleAvatar(
                radius: 14,
                backgroundColor: active ? kSmartQGreen : Colors.grey.shade300,
                child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
              ),
              index == _labels.length - 1 ? const Spacer() : _line(step > index),
            ],
          ),
          const SizedBox(height: 4),
          Text(_labels[index],
              style: TextStyle(
                fontSize: 12,
                color: active ? kSmartQGreen : Colors.grey,
                fontWeight: index == step ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (index) => _unit(context, index)),
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
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: homeProvider.industryList.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final industry = homeProvider.industryList[index];
            final selected = homeProvider.selectedIndusty == industry;
            return SizedBox(
              width: 92,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: selected
                      ? const BorderSide(color: kSmartQGreen, width: 2)
                      : BorderSide.none,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => homeProvider.setSelectedList(industry),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_iconForIndustry(industry),
                                size: 28, color: selected ? kSmartQGreen : null),
                            const SizedBox(height: 8),
                            Text(
                              industry,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: selected ? kSmartQGreen : null,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(Icons.check_circle, color: kSmartQGreen, size: 16),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrganisationStep extends StatefulWidget {
  final HomeProvider homeProvider;
  final Future<void> Function(String) onSelectOrganisation;

  const _OrganisationStep({required this.homeProvider, required this.onSelectOrganisation});

  @override
  State<_OrganisationStep> createState() => _OrganisationStepState();
}

class _OrganisationStepState extends State<_OrganisationStep> {
  String _query = "";
  bool _resolving = false;

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
              : Stack(
                  children: [
                    ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final company = filtered[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.apartment_outlined),
                            title: Text(company),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _resolving
                                ? null
                                : () async {
                                    setState(() => _resolving = true);
                                    await widget.onSelectOrganisation(company);
                                    // If the org has more than one provider, this State is
                                    // still around (now showing the Service Provider step's
                                    // list) so the spinner needs clearing. If it had exactly
                                    // one, we've already navigated away and this is a no-op.
                                    if (mounted) setState(() => _resolving = false);
                                  },
                          ),
                        );
                      },
                    ),
                    if (_resolving)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ProviderStep extends StatefulWidget {
  final HomeProvider homeProvider;
  final ValueChanged<String> onSelectProvider;

  const _ProviderStep({required this.homeProvider, required this.onSelectProvider});

  @override
  State<_ProviderStep> createState() => _ProviderStepState();
}

class _ProviderStepState extends State<_ProviderStep> {
  // Unit IDs are "SP-" + digits only for units with an approved Service Provider registration
  // (CareConnect's onboarding flow -- see SQ_CareConnect/lib/service-provider-no.ts). Confirmed
  // live (device test typing "CH1909" against NKTI's units, which pre-date that registration
  // system) that plenty of real units are still arbitrary free text ("In-coming", "chair 1",
  // etc.) -- those are legacy entries without an approved SP- registration, not something this
  // quick-entry field needs to reach. It's specifically for finding a registered provider by
  // number as that list grows long; legacy units stay reachable by scrolling the plain list
  // below, just not through this field.
  String _digits = "";

  @override
  Widget build(BuildContext context) {
    final homeProvider = widget.homeProvider;
    final filtered = _digits.isEmpty
        ? homeProvider.unitList
        : homeProvider.unitList
            .where((u) => u.replaceAll(RegExp(r'[^0-9]'), '').contains(_digits))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => homeProvider.setCompaniesList(""),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: Text("Organisation: ${homeProvider.selectedCompanies}"),
        ),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => setState(() => _digits = value),
          decoration: const InputDecoration(
            prefixText: "SP-",
            hintText: "Enter Unit ID number",
            prefixIcon: Icon(Icons.tag),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        // Tapping a provider immediately continues -- no separate selected/tick state or
        // Continue button, choosing a provider here IS the action.
        Expanded(
          child: homeProvider.unitList.isEmpty
              ? const Center(child: Text("No service providers found"))
              : filtered.isEmpty
                  ? const Center(child: Text("No matching Unit ID"))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final unit = filtered[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.storefront_outlined),
                            title: Text(unit),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => widget.onSelectProvider(unit),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
