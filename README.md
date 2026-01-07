# GLPI 11 on Cloudron

GLPI (Gestionnaire Libre de Parc Informatique) packaged for **Cloudron** with a clean, secure and explicit installation flow.

This package follows Cloudron best practices and GLPI 11 security requirements.

---

## ⚠️ Important – Mandatory Post-Installation Step

For security reasons, **GLPI does NOT initialize its database automatically**.

After installing the app, you **must run a one-time initialization script manually**.

This is intentional and expected behavior.

---

## 🚀 Post-installation (ONE TIME)

Run the following command **once** from your Cloudron server:

```bash
cloudron exec bash /app/code/init-glpi.sh
```

This script will:
- Initialize the GLPI database schema
- Create all required tables
- Prepare cache and persistent directories
- Create the default administrator account

The script is **idempotent** and will safely exit if GLPI is already initialized.

---

## 🔐 Default credentials

After initialization, log in using:

- **Username:** `glpi`
- **Password:** `glpi`

⚠️ **You must change this password immediately after first login.**

---

## 📂 Persistent data layout

All mutable data is stored in `/app/data` and included in Cloudron backups:

| Purpose | Path |
|------|------|
| Configuration | `/app/data/config` |
| Files / cache | `/app/data/files` |
| Plugins | `/app/data/plugins` |

Application code remains read-only.

---

## 🛠️ Repair / Recovery

If initialization failed or after restoring a backup, you can safely re-run:

```bash
cloudron exec bash /app/code/init-glpi.sh
```

The script will detect existing installations and avoid reinitializing.

---

## 🧠 Technical highlights

- GLPI **11.x**
- PHP **8.3**
- MySQL addon managed by Cloudron
- Front controller routing (`/public/index.php`)
- No writable paths inside the application code
- Cloudron-native lifecycle (install / update / backup / restore)

---

## ✅ Expected state after setup

- Web interface accessible
- Login page working
- Database populated (`glpi_*` tables)
- Installation wizard disabled (normal)
- Cloudron health checks passing

---

## 📌 Notes

- Do **not** run the initialization script more than once on a production instance.
- Always change the default password.
- Use Cloudron backups before major upgrades.

---

## 🧾 License

GLPI is licensed under the GNU General Public License v3.  
This Cloudron packaging contains no modification to GLPI core code.

---

Maintained by **Vitetj**.
