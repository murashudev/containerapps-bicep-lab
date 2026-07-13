# 📘 01_repository-setup.md  
Azure Bicep IaC プロジェクトの初期セットアップ手順  
（containerapps-bicep-lab）

---

## 🎯 目的  
この章では、Azure Container Apps + VNet + Private Endpoint + Front Door（WAF）構成を IaC で構築するための  
**リポジトリの初期セットアップ**を行う。

- GitHub 上にリポジトリを作成  
- ローカルへ clone  
- 初期ディレクトリ構成の作成  
- Bicep モジュールの空ファイルを準備  
- docs（手順書）フォルダの作成  

---

## 📁 完成するディレクトリ構成（この章のゴール）

```
containerapps-bicep-lab/
├─ subscription/
│   └─ rg.bicep
├─ modules/
│   ├─ vnet.bicep
│   ├─ containerapps-env.bicep
│   ├─ containerapp.bicep
│   ├─ acr.bicep
│   ├─ mysql-flex.bicep
│   ├─ loganalytics.bicep
│   ├─ private-endpoints.bicep
│   ├─ keyvault.bicep
│   └─ frontdoor-waf.bicep
├─ parameters/
│   └─ dev.json
├─ docs/
│   ├─ 01_repository-setup.md
│   ├─ 02_vnet-and-subnets.md
│   ├─ 03_containerapps-environment.md
│   ├─ 04_containerapp.md
│   ├─ 05_acr.md
│   ├─ 06_mysql-flexibleserver.md
│   ├─ 07_loganalytics.md
│   ├─ 08_private-endpoints.md
│   ├─ 09_keyvault.md
│   ├─ 10_frontdoor-waf.md
│   ├─ 11_cicd-github-actions.md
│   └─ 12_app-containerization.md
└─ main.bicep
```

---

## 🧭 手順

### 1. GitHub 上にリポジトリを作成  
GitHub Web UI で以下を実施：

- Repository name：`containerapps-bicep-lab`
- README：**作成する（推奨）**
- .gitignore：不要（Bicep は不要）
- License：任意

---

### 2. ローカルへ clone

PowerShell / Git Bash：

```
git clone https://github.com/<your-account>/containerapps-bicep-lab.git
cd containerapps-bicep-lab
```

---

### 3. 初期ディレクトリと空ファイルの作成

PowerShell：

```
mkdir subscription
New-Item subscription/rg.bicep -ItemType File

New-Item main.bicep -ItemType File

mkdir modules
New-Item modules/vnet.bicep -ItemType File
New-Item modules/containerapps-env.bicep -ItemType File
New-Item modules/containerapp.bicep -ItemType File
New-Item modules/acr.bicep -ItemType File
New-Item modules/mysql-flex.bicep -ItemType File
New-Item modules/loganalytics.bicep -ItemType File
New-Item modules/private-endpoints.bicep -ItemType File
New-Item modules/keyvault.bicep -ItemType File
New-Item modules/frontdoor-waf.bicep -ItemType File

mkdir parameters
New-Item parameters/dev.json -ItemType File
```

---

### 4. docs フォルダと章ごとの md ファイル作成

```
mkdir docs

New-Item docs/01_repository-setup.md -ItemType File
New-Item docs/02_vnet-and-subnets.md -ItemType File
New-Item docs/03_containerapps-environment.md -ItemType File
New-Item docs/04_containerapp.md -ItemType File
New-Item docs/05_acr.md -ItemType File
New-Item docs/06_mysql-flexibleserver.md -ItemType File
New-Item docs/07_loganalytics.md -ItemType File
New-Item docs/08_private-endpoints.md -ItemType File
New-Item docs/09_keyvault.md -ItemType File
New-Item docs/10_frontdoor-waf.md -ItemType File
New-Item docs/11_cicd-github-actions.md -ItemType File
New-Item docs/12_app-containerization.md -ItemType File
```

---

### 5. Git へコミット & push

```
git add .
git commit -m "docs: add initial repository setup and directory structure"
git push origin main
```

---

## 🔍 確認ポイント

- `containerapps-bicep-lab` 配下に必要なディレクトリがすべて揃っている  
- Bicep モジュールの空ファイルがすべて存在する  
- docs 配下に 12 章の md が揃っている  
- GitHub 上の main ブランチに push されている  

---

## 🎉 完了  
これで **IaC プロジェクトの初期セットアップは完了**です。  
次章では、配線図の最初の要素である **VNet とサブネット**を構築します。

---

## 🧭 次のステップ（Guided Links）
- **VNet とサブネットの Bicep を書き始めたい**  
- **main.bicep の骨格を作成したい**  