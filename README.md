# GLPI 11 on Cloudron

GLPI (Gestionnaire Libre de Parc Informatique) packaged for **Cloudron** with automatic initialization and LDAP integration.

This package follows Cloudron best practices and GLPI 11 security requirements.

---

## 🚀 Automatic Initialization

**GLPI initializes automatically on first startup!**

The application will:
- Initialize the GLPI database schema automatically in background
- Create all required tables
- Configure persistent directories
- Create the default administrator account
- **Automatically configure and synchronize Cloudron LDAP** (if enabled)

No manual intervention required. The application becomes healthy immediately, initialization completes in the background (30-60 seconds).

### 🔗 LDAP Integration (Automatic)

If LDAP is enabled on your Cloudron instance, the startup script will automatically:
- Configure LDAP authentication with proper field mappings
- Synchronize users from Cloudron LDAP directory  
- Enable LDAP as the default authentication method

The LDAP configuration includes:
- Field mappings: `username`, `mail`, `givenName`, `sn`
- Proper DN and bind configuration
- Automatic user synchronization on first startup

---

## 🔐 Default credentials

After automatic initialization (30-60 seconds), log in using:

- **Username:** `glpi`
- **Password:** `glpi`

⚠️ **You must change this password immediately after first login.**

---

## 📂 Persistent data layout

All mutable data is stored in `/app/data` and included in Cloudron backups:

| Purpose | Path |
|------|------|
| Configuration | `/app/data/config` |
| Files / cache / logs | `/app/data/files` |
| Plugins | `/app/data/plugins` |
| Marketplace | `/app/data/marketplace` |

Application code remains read-only.

---

## 🛠️ Repair / Recovery

GLPI automatically initializes on first startup.

If you need to reinitialize (e.g., after database corruption), delete the configuration:

```bash
cloudron exec rm -f /app/data/config/config_db.php
cloudron restart
```

The app will automatically reinitialize on next startup.

---

## 🧠 Technical highlights

- GLPI **11.0.4**
- PHP **8.3**
- Apache **2.4**
- MySQL addon managed by Cloudron
- LDAP addon integration
- Background initialization (non-blocking startup)
- All data directories symlinked to persistent storage
- Cloudron-native lifecycle (install / update / backup / restore)

---

## ✅ Expected state after setup

- Application healthy immediately
- Web interface accessible
- Database initialization in background
- Login page working after ~30-60 seconds
- LDAP users synchronized automatically
- Cloudron health checks passing

---

## 📌 Notes

- **Fully automatic setup** - No manual commands needed
- Database and LDAP configuration happens automatically on first startup
- Background initialization doesn't block health checks
- Always change the default password after first login
- Use Cloudron backups before major upgrades

---

## 🧾 License

GLPI is licensed under the GNU General Public License v3.  
This Cloudron packaging contains no modification to GLPI core code.

---

## 🔧 Development

Build and deploy:

```bash
cloudron build
cloudron install
```

Or with custom build service:

```bash
cloudron build --set-build-service 'https://builder.example.com' --build-service-token YOUR_TOKEN
cloudron install
```

Maintained by **Vitetj**.
