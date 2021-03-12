WITH
    organization_id_by_vita_partner_id AS (
        select id, (CASE WHEN parent_organization_id IS NULL THEN id ELSE parent_organization_id END) AS organization_id
        from vita_partners
    ),
    client_ids AS
    (
        select distinct client_id
        from tax_returns

        where tax_returns.status >= 102 AND tax_returns.status <= 404 AND tax_returns.status != 403 AND tax_returns.status != 106
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