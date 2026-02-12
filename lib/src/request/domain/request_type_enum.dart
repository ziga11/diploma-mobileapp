enum RequestType {
  signedPayroll,
  signedContract,
  er28Form,
  payrollPassword,
  creditForm,
  transactionAccountChange,
  addressChange,
  childBenefit,
  workPeriod,
  other;

  bool get isFileRequired {
    return const [
      RequestType.creditForm,
      RequestType.transactionAccountChange,
      RequestType.addressChange,
      RequestType.workPeriod,
    ].contains(this);
  }

  String get translationKey {
    return switch (this) {
      RequestType.signedPayroll => "signedPayrollRequest",
      RequestType.signedContract => "signedContractRequest",
      RequestType.er28Form => "er28Form",
      RequestType.payrollPassword => "passwordForPayroll",
      RequestType.creditForm => "creditForm",
      RequestType.transactionAccountChange => "transactionAccountChangeRequest",
      RequestType.addressChange => "addressChangeRequest",
      RequestType.childBenefit => "childBenefit",
      RequestType.workPeriod => "workPeriod",
      RequestType.other => "other",
    };
  }
}
