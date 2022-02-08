WITH
    organization_id_by_vita_partner_id AS (
        select id, (CASE WHEN parent_organization_id IS NULL THEN id ELSE parent_organization_id END) AS organization_id
        from vita_partners
    ),
    client_ids AS
        (
            select distinct tax_returns.client_id
            from tax_returns
                     INNER JOIN intakes ON (intakes.client_id) = tax_returns.client_id

            where tax_returns.state NOT IN ('intake_before_consent', 'intake_in_progress', 'intake_greeter_info_requested', 'intake_needs_doc_help', 'file_mailed', 'file_accepted', 'file_not_filing', 'file_hold', 'file_fraud_hold')
        ),
    partner_and_client_counts AS (
        SELECT organization_id, count(clients.id) as active_client_count
        FROM organization_id_by_vita_partner_id
                 LEFT OUTER JOIN clients ON organization_id_by_vita_partner_id.id = clients.vita_partner_id
        WHERE clients.id IN (select client_id from client_ids) GROUP BY organization_id
    )
SELECT id as vita_partner_id, name, capacity_limit, CASE WHEN partner_and_client_counts.active_client_count IS NULL THEN 0 ELSE partner_and_client_counts.active_client_count END
FROM vita_partners
         LEFT OUTER JOIN partner_and_client_counts ON vita_partners.id=partner_and_client_counts.organization_id WHERE parent_organization_id IS NULL;

