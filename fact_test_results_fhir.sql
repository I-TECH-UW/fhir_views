CREATE VIEW fact_test_results AS
SELECT O.id, O.effective.dateTime, subject.patientId,C.code as test_code,C.display as test_text,CC.code as result_code,CC.display as result_text, O.value.quantity.value as numerical_value,
       O.value.quantity.unit as numerical_units, O.value.quantity.system as numerical_system
from observation AS O
LEFT JOIN (
    SELECT O.id,C.code,C.display from observation AS O LATERAL VIEW explode(code.coding) as C
) C on O.id=C.id
LEFT JOIN (
    SELECT O.id,C.code,C.display from observation AS O LATERAL VIEW explode(value.codeableConcept.coding) as C
) CC on O.id=CC.id
