CREATE VIEW fact_clinical_visits AS

SELECT E.id,E.patientid,E.doctor_id,E.doctor_name, E.date, E.organizationID, E.organization_name, V.code, V.visit_type FROM (

SELECT E.id, E.subject.patientID as patientid,  concat_ws(" ",E.participant.individual.practitionerId) as doctor_id,
       concat_ws(" ",E.participant.individual.display) as doctor_name, concat_ws(" ",E.participant.period.start) as date,
       serviceProvider.organizationID, serviceProvider.display as organization_name,
ident.value as identifiter
                  from encounter AS E LATERAL VIEW explode(identifier) as ident
                  WHERE ident.use = "official") E
LEFT JOIN (
SELECT E.id, concat_ws(" ",coding.code) as code, concat_ws(" ",coding.display) as visit_type
                  from encounter AS E LATERAL VIEW explode(type.coding) as coding
) V on E.id = V.id