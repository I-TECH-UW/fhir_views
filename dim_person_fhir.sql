CREATE OR REPLACE VIEW dim_person AS
SELECT P.id,N.firstname,N.lastname,M.firstname as firstname_maiden, M.lastname as lastname_maiden, P.gender,P.birthDate,I.drivers_license,
       I.ssn, I.mrn, I.passport, I.synthea, Phone.phone_number, Add.city, Add.state, Add.zip
       from patient AS P
LEFT JOIN (
    SELECT id,
    MAX(identifier) FILTER (WHERE system = "urn:oid:2.16.840.1.113883.4.3.25") AS drivers_license,
    MAX(identifier) FILTER (WHERE system = "http://hl7.org/fhir/sid/us-ssn") AS ssn,
    MAX(identifier) FILTER (WHERE system = "http://hospital.smarthealthit.org") AS mrn,
    MAX(identifier) FILTER (WHERE system = "http://standardhealthrecord.org/fhir/StructureDefinition/passportNumber") AS passport,
    MAX(identifier) FILTER (WHERE system = "https://github.com/synthetichealth/synthea") AS synthea
from (
    SELECT P.id, ident.value as identifier, ident.system as system, concat_ws(" ",ident.type.coding.display) as id_type
                  from patient AS P LATERAL VIEW OUTER explode(identifier) as ident
) group by id
) I on P.id = I.id
LEFT JOIN (
    SELECT P.id,names.family as lastname,concat_ws(" ",names.given) as firstname, names.use  from patient AS P
LATERAL VIEW OUTER explode(name) as names
WHERE names.use = "official"
) N on P.id = N.id
LEFT JOIN (
    SELECT P.id,names.family as lastname,concat_ws(" ",names.given) as firstname, names.use  from patient AS P
LATERAL VIEW OUTER explode(name) as names
WHERE names.use = "maiden"
) M on P.id = M.id
LEFT JOIN (
    SELECT P.id,tele.value as phone_number  from patient AS P
LATERAL VIEW OUTER explode(telecom) as tele
       ) Phone on P.id = Phone.id
LEFT JOIN (
    SELECT P.id,add.city as city, add.state as state, add.postalCode as zip  from patient AS P
LATERAL VIEW OUTER explode(address) as add
       ) Add on P.id = Add.id
