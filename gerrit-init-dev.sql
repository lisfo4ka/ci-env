-- Insert the base values for the initial Gerrit user. This user will
-- become the administrator of the server. As this user is a local
-- user it will not be able to login through the web UI.
begin;

\set gerrit_admin_account_id 1
\set gerrit_admin_group_id 1

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
SET email_address = 'test@example.com',
    password = NULL
WHERE
    external_id = 'mailto:admin@example.com';

end;
