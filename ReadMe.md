# 🛡️ ClamCenter

### **Introduction**
*Alias Void. The AI PowerUser (AIPU).*
IDC if you don't like AI. it is a tool that is supposed to be used, and I am using it. It isn't like I am doing less work, because I have to manually fix the 100 issues the code has.
---

## 📌 About This Project

I have worked hard—not really, but yea—and configured the first (I think) Windows Defender-like UI (CLI) for Linux that acts like a bare-bones security center. I know it looks awful and is made by AI (remember AI is a tool to make things easier, so please be lenient, I am new!), but this could make people's lives easier. 

I would like to improve it, but it will be hard to improve it further without a community of actual proper coders. I will try my best though, because this would be a step to make the internet better again by giving Linux an actual antivirus UI.

---

## ⚙️ Why I Included The Configs As Well

I am uploading these configs because it was hard for myself to make them, so I was hoping to make someone else's life easier. Also, I want them to be checked out by a pro! I made them with AI help, so I was hoping that a pro would come along and offer any advice to make them better. 

*BTW, `freshclam.conf` is default—I didn't change anything there because it was not needed for me, but if there is something I can do better, please: it would be my pleasure to hear you out in 'discussions'.*

---

## 🚀 Future Plans

I will contact anyone willing to help. My next goal for this project is to make it easier with an actual proper GUI with buttons and not a CLI. More automated downloads of security apps. Most importantly more supported distros.

---

## 📦 Dependencies Required

If your distro isn't supported by the automatic dependency installer, please ensure these packages are installed:

* `clamav`
* `inotify-tools`
* `zip` / `unzip`
* `libnotify`

---

## 🛠️ Installation

I have provided an installation script (`install.sh`). It copies the files to their designated system locations, so it should work across distros! *(Haven't heavily tested it yet, though—you can check it out if you want).*

> **Note:** The script will automatically download dependencies if you are on **Arch**, **Ubuntu/Debian**. IT WILL ALSO DELETE AND RELPACE ALL YOUR CLAMAV CONFIGS!!! You will need to install dependencies manually on other distributions. The included configs have `clamonacc` (on-access scanning) enabled by default.

*THIS WILL DELETE YOUR CLAMAV CONFIGS!!!
### Quick Install Command:
```bash
git clone [https://github.com/YOUR_USERNAME/ClamCenter.git](https://github.com/YOUR_USERNAME/ClamCenter.git)
cd ClamCenter
sudo ./install.sh
```

ps: there is a malware vault/extraction that can be done. Because any malware or virus that gets quarantined gets zipped and encrypted. So if you want to you can bring them out by typing "777" on the select menu that will bring you to the vault menu and the code can be changed manually inside the Defender bin, also the zip password is "infected" that also can be changed manually by editing the quarantine-notifyer bin file.
