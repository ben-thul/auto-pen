Auto Pen
===

Synopsis
---
Auto pen is a mechanism to simplify the application of module signing in our SQL Server environment. In short, by placing the name of the object (i.e. stored procedure, trigger, or certain types of user-defined functions) you want signed along with the name of the certificate into a special table, any `CREATE` or `ALTER` operations on those objects will have the signature automatically applied. It supports a full N:M mapping (that is, a certificate can sign many objects and many certificates can sign any one object). If a signature cannot be applied for whatever reason, the operation that invoked Auto Pen will be rolled back with an error returned to the caller.

This mechanism allows us to grant permissions via the certificate in a way that cannot be forgotten on deployment (since signatures are dropped on `ALTER` operations). Similarly, it also allows developers to change affected objects in environments where they are enabled to do so and have the signature work for them without them having to know about what is admittedly an intermediate security topic in SQL Server.

High level
---
This solution is comprised of three parts, each of which is scoped to a particular database

1. The `admin.ObjectSignatures` table that stores the object-to-certificate relationships.
1. The `admin.SignObject` stored procedure. This proc actually applies the signatures. **Note**: calling it with no arguments will attempt to apply *all* of the signatures that are in the table.
1. The `ModuleSigningDDLTrigger` DDL trigger. This is invoked on the caller's behalf any time a `CREATE` or `ALTER` statement of the appropriate type is attempted.

All three need to be deployed to a database for the mechanism to work.

Assumptions
---
* In the general case, the certificate's private key should be signed by the database master key (and the database master key signed with the service master key) to avoid having to open it explicitly with a password. But the solution supports signing with any certificate provided it's open at the time of the triggering operation.
* The certificate should exist ahead of time. If not and a triggering operation is attempted on an object represented in the table, that operation will fail.


Auto pen?
---
From [wikipedia](https://en.wikipedia.org/wiki/Autopen):
> An autopen or signing machine is a device used for the automatic signing of a signature or autograph. Many celebrities, politicians and public figures receive hundreds of letters a day, many of which request a personal reply; this leads to a situation in which either the individual must artificially reproduce their signature or heavily limit the number of recipients who receive a personal response.

Further reading
---
* [Module signing](https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/signing-stored-procedures-in-sql-server)
* [Ownership Chaining](https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/authorization-and-permissions-in-sql-server#procedural-code-and-ownership-chaining)
* [Encryption hierarchy](https://docs.microsoft.com/en-us/sql/relational-databases/security/encryption/encryption-hierarchy)