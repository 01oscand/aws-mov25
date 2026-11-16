# AWS vecka 46 - IaC med CloudFormation (Novatrix AB)

Kurs: Amazon Web Services, MOV25. Uppgift 5 av 8 (G).  Region: `eu-north-1`.

## Syfte och avgransning

Denna mapp beskriver ett **separat v46-labb** med ett privat AWS-nat (VPC + tre subnat), internet gateway, routing, Security Group och en EC2-instans med Apache. Resurserna provisioneras med tva CloudFormation-templates. Den befintliga WordPress-/RDS-/EFS-miljon fran v42-v45 andras eller raderas **inte**. Full WordPress-stack som kod ingar inte i denna G-avgransning.

## Filer

- `natverk.yaml` - skapar `novatrix-v46-vpc`, subnat, internet gateway, publik route table och `novatrix-v46-web-sg`.
- `webb.yaml` - importerar natverksvarden och skapar `novatrix-v46-web` med Apache via EC2 UserData.
- `arkitektur-v46.png` - natverks-/stackoversikt.
- `PRAKTISK_GUIDE_v46.md` - komplett steg-for-steg-guide.
- `github-sammanfattning.txt` - kort text till huvudrepots README.

## Resursnamn

| Objekt | Namn / intervall |
|---|---|
| Nätverksstack | `novatrix-v46-natverk` |
| Webbserverstack | `novatrix-v46-webb` |
| VPC | `novatrix-v46-vpc`, `10.46.0.0/16` |
| Publikt subnät | `novatrix-v46-public`, `10.46.1.0/24` |
| Privata subnät | `novatrix-v46-private-a` (`10.46.2.0/24`), `novatrix-v46-private-b` (`10.46.4.0/24`) |
| Internet Gateway | `novatrix-v46-igw` |
| Publik route table | `novatrix-v46-public-rt` |
| Security Group | `novatrix-v46-web-sg`: HTTP 80 fran internet, SSH 22 endast fran `AdminCidr` |
| EC2 | `novatrix-v46-web`, Amazon Linux 2023, Apache |

Privata subnat har **ingen** route till internet gateway eller NAT. Endast det publika subnatet har `0.0.0.0/0` till internet gateway. Ingen HTTPS-konfiguration ingar - HTTP pa port 80 används for verifiering.

## Innan deploy

1. Se over budget och AWS-kostnader. En ny EC2-instans och publik IPv4 kan medfora kostnader.
2. Kontrollera att EC2 key pair `novatrix-web-key` finns i `eu-north-1`.
3. Ta fram **din egen Windows-dators** publika IPv4 med `curl.exe https://checkip.amazonaws.com` i PowerShell; lagg till `/32`. Anvand **inte** CloudShell:s IP som SSH-kalla.
4. Sakerstall att inga stackar med samma namn finns sedan tidigare. Deployment skapar nytt nar de inte finns, annars uppdaterar den befintliga stackar.

## Deploy med AWS CloudShell

Kopiera forst filerna till GitHub. I CloudShell (Stockholm, Bash):

```bash
aws sts get-caller-identity
aws configure set region eu-north-1

git clone https://github.com/01oscand/aws-mov25.git
cd aws-mov25/v46

# BYT UT med din egen publika IPv4, inte CloudShells
ADMIN_CIDR='DIN-EGEN-IP/32'

aws cloudformation validate-template --template-body file://natverk.yaml --region eu-north-1
aws cloudformation validate-template --template-body file://webb.yaml --region eu-north-1

aws cloudformation deploy \
  --template-file natverk.yaml \
  --stack-name novatrix-v46-natverk \
  --parameter-overrides "AdminCidr=${ADMIN_CIDR}" \
  --region eu-north-1 \
  --no-fail-on-empty-changeset

aws cloudformation deploy \
  --template-file webb.yaml \
  --stack-name novatrix-v46-webb \
  --parameter-overrides KeyPairName=novatrix-web-key InstanceType=t3.micro \
  --region eu-north-1 \
  --no-fail-on-empty-changeset
```

Deployer gor **andringar i ditt AWS-konto** och skapar faktiska resurser. Kor dem bara om du kontrollerat konto/region och kostnad.

## Verifiera med kommandon

```bash
aws cloudformation describe-stacks --stack-name novatrix-v46-natverk --query 'Stacks[0].StackStatus' --output text --region eu-north-1
aws cloudformation describe-stacks --stack-name novatrix-v46-webb --query 'Stacks[0].StackStatus' --output text --region eu-north-1
aws cloudformation describe-stacks --stack-name novatrix-v46-webb --query 'Stacks[0].Outputs' --output table --region eu-north-1
aws cloudformation list-stack-resources --stack-name novatrix-v46-natverk --region eu-north-1 --output table
```

Öppna `http://<PublicIPv4 från Outputs>` i din webblasare och kontrollera texten **Novatrix AB - CloudFormation v46**. Kontrollera att port 22 bara ar oppen fran din egen publika IP via SG-konfigurationen.

## Versionshantering och kontrollerad uppdatering

Andra `LabStage`-taggen i `webb.yaml` fran `forsta` till `uppdaterad` i VS Code. Detta ar en avsiktligt liten, icke-destruktiv andring. Kor lokalt:

```powershell
git diff -- v46/webb.yaml
git add v46/webb.yaml
git commit -m "v46: uppdatera LabStage-tagg i CloudFormation"
git push
git log --oneline -3 -- v46/webb.yaml
```

I CloudShell fran `aws-mov25/v46`:

```bash
git pull --ff-only
aws cloudformation deploy \
  --template-file webb.yaml \
  --stack-name novatrix-v46-webb \
  --parameter-overrides KeyPairName=novatrix-web-key InstanceType=t3.micro \
  --region eu-north-1 \
  --no-fail-on-empty-changeset
aws cloudformation describe-stacks --stack-name novatrix-v46-webb --query 'Stacks[0].StackStatus' --output text --region eu-north-1
```

Kontrollera `UPDATE_COMPLETE` och taggen `LabStage=uppdaterad` pa EC2-instansen. Git-historiken gor det mojligt att se vem som andrat vad och nar, jamfora versioner och backa till en tidigare version.

## Återskapa från repot

1. Kontrollera att du star i ratt konto och `eu-north-1`, och att `novatrix-web-key` finns.
2. Klona repot och ga till `v46`.
3. Ange din aktuella publika IP som `ADMIN_CIDR`.
4. Validera bada YAML-filerna.
5. Deploya `novatrix-v46-natverk` och sedan `novatrix-v46-webb`.
6. Verifiera `CREATE_COMPLETE`, `Outputs`, EC2-instansens placering och HTTP-svaret.
7. Vid uppdateringar: andra YAML, committa i Git, pull i CloudShell och deploya igen.

**Obs:** Detta aterskapar v46-demo-arkitekturen, inte din ursprungliga v45 WordPress-databas och EFS-data.

## Rensa labbmiljon (endast om du vill, efter godkand inlamning)

**Radera aldrig v42-v45-resurserna.** Om du uttryckligen vill riva den *separata v46-demomiljon* som CloudFormation skapade, tas den bort i omvand ordning:

```bash
aws cloudformation delete-stack --stack-name novatrix-v46-webb --region eu-north-1
aws cloudformation wait stack-delete-complete --stack-name novatrix-v46-webb --region eu-north-1
aws cloudformation delete-stack --stack-name novatrix-v46-natverk --region eu-north-1
```

Detta terminerar **v46-EC2-instansen** och raderar **v46-VPC:n**, inte originalmiljon. Kor inte raderingskommandona om du vill behalla labbet. Om koden har andrats sedan deploy, granska beroenden och resurser innan borttagning.

## Säkerhet

- Aldrig privata SSH-nycklar, hemligheter eller `wp-config.php` i GitHub.
- SSH 22 endast fran egen publika IPv4 `/32`.
- HTTP 80 oppen for demonstrationssidan; HTTPS ar inte konfigurerat.
- Inga NAT Gateways och ingen publik RDS.
- EC2 med IMDSv2 (`HttpTokens: required`).
- Ursprunglig WordPress-, RDS- och EFS-miljo fran tidigare veckor lamnas oforandrad.
