# 🚀 Panduan Deployment ke Azure App Service

## Langkah 1: Persiapan Azure SQL Database

### 1.1 Buat Azure SQL Database
1. Login ke [Azure Portal](https://portal.azure.com)
2. Klik "Create a resource" → "Databases" → "SQL Database"
3. Isi informasi:
   - **Database name**: `EquipmentManagement`
   - **Server**: Buat server baru atau pilih yang sudah ada
   - **Pricing tier**: Pilih sesuai kebutuhan (Basic untuk testing)
4. Klik "Review + create" → "Create"

### 1.2 Setup Database Schema
1. Download dan install [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio) atau [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
2. Connect ke Azure SQL Database menggunakan connection string dari Azure Portal
3. Jalankan script `database/create-tables.sql` yang sudah disediakan
4. Pastikan tabel `EquipmentImages` dan stored procedures berhasil dibuat

### 1.3 Catat Connection String
1. Di Azure Portal, buka SQL Database yang sudah dibuat
2. Klik "Connection strings" di menu kiri
3. Copy connection string untuk "ADO.NET"
4. Simpan untuk digunakan nanti

## Langkah 2: Persiapan Kode untuk Production

### 2.1 Install Dependencies
```bash
npm install
```

### 2.2 Setup Environment Variables
1. Copy file `.env.example` menjadi `.env.local`
2. Isi dengan data Azure SQL Database Anda:
```env
DB_SERVER=your-server.database.windows.net
DB_DATABASE=EquipmentManagement
DB_USER=your-username
DB_PASSWORD=your-password
NEXTAUTH_SECRET=generate-random-secret-key
NEXTAUTH_URL=https://your-app-name.azurewebsites.net
NODE_ENV=production
```

### 2.3 Test Local Connection
```bash
npm run dev
```
Pastikan aplikasi bisa connect ke Azure SQL Database dari local.

## Langkah 3: Deploy ke Azure App Service

### 3.1 Buat Azure App Service
1. Di Azure Portal, klik "Create a resource" → "Web App"
2. Isi informasi:
   - **App name**: `equipment-management-app` (atau nama unik lainnya)
   - **Runtime stack**: `Node 20 LTS`
   - **Operating System**: `Linux`
   - **Region**: Pilih yang terdekat
3. Klik "Review + create" → "Create"

### 3.2 Setup Deployment dari GitHub (Recommended)

#### Option A: GitHub Actions (Otomatis)
1. Push kode ke GitHub repository
2. Di Azure App Service, buka "Deployment Center"
3. Pilih "GitHub" sebagai source
4. Authorize dan pilih repository
5. Pilih branch `main`
6. Azure akan otomatis setup GitHub Actions

#### Option B: Manual Upload
1. Build aplikasi:
```bash
npm run build
```
2. Compress folder project menjadi ZIP
3. Di Azure App Service, buka "Advanced Tools" → "Go"
4. Upload ZIP file ke `/home/site/wwwroot`

### 3.3 Configure App Service Settings
1. Di Azure App Service, buka "Configuration"
2. Tambahkan Application Settings:
```
DB_SERVER = your-server.database.windows.net
DB_DATABASE = EquipmentManagement
DB_USER = your-username
DB_PASSWORD = your-password
NEXTAUTH_SECRET = your-secret-key
NEXTAUTH_URL = https://your-app-name.azurewebsites.net
NODE_ENV = production
WEBSITE_NODE_DEFAULT_VERSION = 20-lts
```
3. Klik "Save"

### 3.4 Configure Startup Command
1. Di "Configuration" → "General settings"
2. Set **Startup Command**: `npm start`
3. Klik "Save"

## Langkah 4: Setup Network Security

### 4.1 Configure SQL Database Firewall
1. Di Azure SQL Database, buka "Firewalls and virtual networks"
2. Tambahkan rule untuk Azure services:
   - **Rule name**: `AllowAzureServices`
   - **Start IP**: `0.0.0.0`
   - **End IP**: `0.0.0.0`
3. Klik "Save"

### 4.2 Test Connection
1. Buka URL App Service: `https://your-app-name.azurewebsites.net`
2. Test login dengan credentials:
   - admin / password
   - user1 / user123
   - operator / operator123

## Langkah 5: Monitoring dan Troubleshooting

### 5.1 View Logs
1. Di Azure App Service, buka "Log stream"
2. Atau gunakan Azure CLI:
```bash
az webapp log tail --name your-app-name --resource-group your-resource-group
```

### 5.2 Common Issues dan Solutions

#### Issue: "Cannot connect to database"
**Solution**: 
- Pastikan firewall SQL Database sudah dikonfigurasi
- Cek connection string di Application Settings
- Pastikan username/password benar

#### Issue: "Module not found"
**Solution**:
- Pastikan `package.json` sudah include semua dependencies
- Run `npm install` sebelum deploy
- Cek Node.js version di App Service

#### Issue: "Application failed to start"
**Solution**:
- Cek startup command: `npm start`
- Pastikan `npm run build` berhasil
- Cek logs untuk error details

## Langkah 6: Custom Domain (Optional)

### 6.1 Add Custom Domain
1. Di Azure App Service, buka "Custom domains"
2. Klik "Add custom domain"
3. Enter domain name dan verify ownership
4. Update DNS records sesuai instruksi Azure

### 6.2 SSL Certificate
1. Di "TLS/SSL settings"
2. Klik "Private Key Certificates (.pfx)"
3. Upload certificate atau gunakan App Service Managed Certificate

## Langkah 7: Backup dan Maintenance

### 7.1 Database Backup
1. Azure SQL Database otomatis backup
2. Untuk manual backup, gunakan Azure Portal atau SQL commands

### 7.2 Application Backup
1. Di App Service, buka "Backups"
2. Configure automatic backup ke Storage Account

## 🎉 Selesai!

Aplikasi Equipment Management sudah berhasil di-deploy ke Azure!

**URL Aplikasi**: `https://your-app-name.azurewebsites.net`

### Demo Credentials:
- **Admin**: admin / password
- **User**: user1 / user123  
- **Operator**: operator / operator123

### Support:
Jika ada masalah, cek:
1. Azure App Service logs
2. SQL Database connection
3. Application Settings configuration
