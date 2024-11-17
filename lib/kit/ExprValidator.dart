import 'package:expressions/expressions.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ExprValidator extends BaseValidator<String> {
  /// Constructor for the false value validator.
  const ExprValidator({
    /// {@macro base_validator_error_text}
    super.errorText,

    /// {@macro base_validator_null_check}
    super.checkNullOrEmpty,
  });

  @override
  String get translatedErrorText =>
      FormBuilderLocalizations.current.mustBeFalseErrorText;

  @override
  String? validateValue(String valueCandidate) {
    var expr = Expression.tryParse(valueCandidate);
    return expr != null ? null : errorText;
  }
}
