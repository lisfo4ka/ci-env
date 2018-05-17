-- Insert the base values for the initial Gerrit user. This user will
-- become the administrator of the server. As this user is a local
-- user it will not be able to login through the web UI.
begin;

\set gerrit_admin_account_id 1
\set gerrit_admin_group_id 1

{% if tools.gerrit.gerrit_auth_type == "DEVELOPMENT_BECOME_ANY_ACCOUNT" %}
/*
*
* For DEVELOPMENT mode we will have already user created in DB
* We need only update its password and email
*
*/

-- password is secret
UPDATE account_external_ids
SET email_address = NULL,
    password = 'bcrypt:4:LQxyNT+l97/F/Mt4gpOcSQ==:b2MP1Ycrm7mv+Deg4ndJIEI0suhLQUFA'
WHERE
    external_id = 'username:admin';

UPDATE account_external_ids
SET email_address = '{{ secrets.gerrit_admin.email }}',
    password = NULL
WHERE
    external_id = 'mailto:admin@example.com';

{% elif tools.gerrit.gerrit_auth_type == "OAUTH" %}
/*
*
* For OAUTH mode we need to create internal admin account to manage
* gerrit, we will also add standard OAUTH accounts to admin group
*
*/

INSERT INTO account_external_ids
VALUES (:gerrit_admin_account_id,
        NULL,
        'bcrypt:4:LQxyNT+l97/F/Mt4gpOcSQ==:b2MP1Ycrm7mv+Deg4ndJIEI0suhLQUFA',
        'username:admin');

INSERT INTO account_external_ids
VALUES (:gerrit_admin_account_id,
        '{{ secrets.gerrit_admin.email }}',
        NULL,
        'mailto:{{ secrets.gerrit_admin.email }}');


-- Add local user to administrator group.

INSERT INTO account_group_members
VALUES (:gerrit_admin_account_id,
        :gerrit_admin_group_id);

-- Insert the audit information.

INSERT INTO account_group_members_audit
VALUES (:gerrit_admin_account_id,
        NULL,
        NULL,
        :gerrit_admin_account_id,
        :gerrit_admin_group_id,
        now());


-- Insert the internal Gerrit user which is connected to the
-- account_external_id we created before.

INSERT INTO accounts
VALUES (now(),
        'Administrator',
        NULL,
        'N',
        :gerrit_admin_account_id);

{% endif %}

end;
