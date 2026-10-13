import 'package:flutter/material.dart';


enum PerkType { free, credit, discount, trial }

enum ReqKind { open, email, githubPack, verify, faculty, other }

class Perk {
  final String name;
  final String desc;
  final String benefit;
  final PerkType type;
  final String req;
  final String url;
  final DateTime? addedAt;

  const Perk(this.name, this.desc, this.benefit, this.type, this.req, this.url,
      {this.addedAt});

  /// True for 14 days after you add it. Use it for a "NEW" badge.
  bool get isNew =>
      addedAt != null && DateTime.now().difference(addedAt!).inDays < 14;

  factory Perk.fromMap(Map<String, dynamic> m, {DateTime? addedAt}) => Perk(
        m['name'] as String? ?? '',
        m['desc'] as String? ?? '',
        m['benefit'] as String? ?? '',
        PerkType.values.firstWhere(
          (t) => t.name == m['type'],
          orElse: () => PerkType.free,
        ),
        m['req'] as String? ?? 'Student (Email)',
        m['url'] as String? ?? '',
        addedAt: addedAt ??
            (m['addedAt'] is DateTime
                ? m['addedAt'] as DateTime
                : m['addedAt'] is String
                    ? DateTime.tryParse(m['addedAt'])
                    : null),
      );

  ReqKind get reqKind {
    final s = req.toLowerCase();
    if (s.contains('faculty') ||
        s.contains('institution') ||
        s.contains('admin')) {
      return ReqKind.faculty;
    }
    if (s.contains('github pack')) return ReqKind.githubPack;
    if (s.contains('open to all') || s.contains('open source')) {
      return ReqKind.open;
    }
    if (s.contains('sheerid') ||
        s.contains('unidays') ||
        s.contains('id.me') ||
        s.contains('verif') ||
        s.contains('proof') ||
        s.contains('isic') ||
        RegExp(r'\bid\b').hasMatch(s)) {
      return ReqKind.verify;
    }
    if (s.contains('email')) return ReqKind.email;
    return ReqKind.other;
  }
}

Perk findOrCreatePerk({
  required String name,
  String desc = '',
  String benefit = '',
  PerkType type = PerkType.free,
  String req = 'Student (Email)',
  String url = '',
}) {
  final nameClean = name.trim().toLowerCase();
  for (final cat in perkCategories) {
    for (final p in cat.perks) {
      final pNameClean = p.name.trim().toLowerCase();
      if (pNameClean == nameClean ||
          pNameClean.contains(nameClean) ||
          nameClean.contains(pNameClean)) {
        return p;
      }
    }
  }
  return Perk(name, desc, benefit, type, req, url);
}

class PerkCategory {
  final String title;
  final String shortTitle;
  final String blurb;
  final IconData icon;
  final Color color;
  final Color tint;
  final bool facultyOnly;
  final List<Perk> perks;

  const PerkCategory({
    required this.title,
    required this.shortTitle,
    required this.blurb,
    required this.icon,
    required this.color,
    required this.tint,
    required this.perks,
    this.facultyOnly = false,
  });
}

const Map<String, String> perkLogos = {
  // Cloud & Infrastructure
  'Azure for Students': 'lib/assets/logos/microsoft.svg',
  'DigitalOcean': 'lib/assets/logos/digitalocean.svg',
  'AWS Educate': 'lib/assets/logos/aws.svg',
  'Google Cloud': 'lib/assets/logos/google_cloud.svg',
  'IBM Cloud': 'lib/assets/logos/ibm.svg',
  'Oracle Cloud': 'lib/assets/logos/oracle.svg',
  'Heroku': 'lib/assets/logos/heroku.svg',
  'Vercel': 'lib/assets/logos/vercel.svg',
  'Netlify': 'lib/assets/logos/netlify.svg',
  'Railway': 'lib/assets/logos/railway.svg',
  'Render': 'lib/assets/logos/render.svg',
  'Namecheap': 'lib/assets/logos/namecheap.svg',
  'Name.com': 'lib/assets/logos/name.svg',
  'MongoDB Atlas': 'lib/assets/logos/mongodb.svg',
  'PlanetScale': 'lib/assets/logos/planetscale.svg',
  'Supabase': 'lib/assets/logos/supabase.svg',
  'Cloudflare': 'lib/assets/logos/cloudflare.svg',
  '.TECH Domain': 'lib/assets/logos/tech.svg',

  // Developer Tools & IDEs
  'GitHub Student Pack': 'lib/assets/logos/github.svg',
  'GitHub Copilot': 'lib/assets/logos/github.svg',
  'GitHub Campus': 'lib/assets/logos/github.svg',
  'JetBrains': 'lib/assets/logos/jetbrains.svg',
  'Visual Studio': 'lib/assets/logos/visual_studio.svg',
  'GitKraken': 'lib/assets/logos/gitkraken.svg',
  'GitLens Pro': 'lib/assets/logos/gitkraken.svg',
  'Tower': 'lib/assets/logos/tower.svg',
  'Termius': 'lib/assets/logos/terminus.svg',
  'Postman': 'lib/assets/logos/postman.svg',
  'Insomnia': 'lib/assets/logos/insomnia.svg',
  'Polypane': 'lib/assets/logos/polypane.svg',
  'Replit': 'lib/assets/logos/replit.svg',
  'CodeSandbox': 'lib/assets/logos/codesandbox.svg',
  'Bootstrap Studio': 'lib/assets/logos/bootstrap.svg',
  'Unity': 'lib/assets/logos/unity.svg',
  'Unreal Engine': 'lib/assets/logos/unreal_engine.svg',
  'Navicat': 'lib/assets/logos/navicat.svg',
  'PopSQL': 'lib/assets/logos/popsql.svg',
  'Working Copy': 'lib/assets/logos/working_copy.svg',
  'Sentry': 'lib/assets/logos/sentry.svg',
  'Codecov': 'lib/assets/logos/codecov.svg',
  'DeepSource': 'lib/assets/logos/deepsource.svg',
  'VMware Workstation': 'lib/assets/logos/vmware_workstation.svg',
  'Cursor': 'lib/assets/logos/cursor.svg',
  'Lovable': 'lib/assets/logos/lovable.svg',
  'FlutterFlow': 'lib/assets/logos/flutterflow.svg',
  'n8n': 'lib/assets/logos/n8n.svg',
  'Antigravity': 'lib/assets/logos/antigravity.svg',
  'v0.app': 'lib/assets/logos/v0.svg',

  // Security & Privacy
  '1Password': 'lib/assets/logos/1password.svg',
  'Bitwarden': 'lib/assets/logos/bitwarden.svg',
  'Dashlane': 'lib/assets/logos/dashlane.svg',
  'HackTheBox': 'lib/assets/logos/hackthebox.svg',
  'TryHackMe': 'lib/assets/logos/tryhackme.svg',
  'PentesterLab': 'lib/assets/logos/pentesterlab.svg',
  'Shodan': 'lib/assets/logos/shodan.svg',
  'Maltego': 'lib/assets/logos/maltego.svg',
  'Nessus': 'lib/assets/logos/nessus.svg',
  'Cryptohack': 'lib/assets/logos/cryptohack.svg',
  'OverTheWire': 'lib/assets/logos/overthewire.svg',
  'PicoCTF': 'lib/assets/logos/picoctf.svg',
  'Surfshark': 'lib/assets/logos/surfshark.svg',
  'NordVPN': 'lib/assets/logos/nordvpn.svg',
  'Snyk': 'lib/assets/logos/snyk.svg',

  // Design & Creative
  'Figma': 'lib/assets/logos/figma.svg',
  'Canva': 'lib/assets/logos/canva.svg',
  'Adobe CC': 'lib/assets/logos/adobe.svg',
  'Autodesk': 'lib/assets/logos/autodesk.svg',
  'Blender': 'lib/assets/logos/blender.svg',
  'Sketch': 'lib/assets/logos/sketch.svg',
  'Framer': 'lib/assets/logos/framer.svg',
  'Webflow': 'lib/assets/logos/webflow.svg',
  'Icons8': 'lib/assets/logos/icons8.svg',
  'IconScout': 'lib/assets/logos/iconscout.svg',
  'DaVinci Resolve': 'lib/assets/logos/davinci_resolve.svg',
  'Descript': 'lib/assets/logos/descrip.svg',
  'ThemeIsle': 'lib/assets/logos/themeisle.svg',

  // AI & Data Science
  'Google Gemini': 'lib/assets/logos/gemini.svg',
  'Perplexity Pro': 'lib/assets/logos/perplexity.svg',
  'OpenAI API': 'lib/assets/logos/openai.svg',
  'Google Colab': 'lib/assets/logos/google_colab.svg',
  'Kaggle': 'lib/assets/logos/kaggle.svg',
  'HuggingFace': 'lib/assets/logos/huggingface.svg',
  'Tableau': 'lib/assets/logos/tableau.svg',
  'MATLAB': 'lib/assets/logos/matlab.svg',
  'Deepnote': 'lib/assets/logos/deepnote.svg',
  'Wolfram|Alpha': 'lib/assets/logos/wolfram_alpha.svg',
  'SQLGate': 'lib/assets/logos/sqlgate.svg',
  'ChatGPT Plus': 'lib/assets/logos/chatgpt.svg',
  'HyperWrite': 'lib/assets/logos/hyperwrite.svg',
  'Julius AI': 'lib/assets/logos/julius.svg',

  // Courses & Certifications
  'Coursera': 'lib/assets/logos/coursera.svg',
  'edX': 'lib/assets/logos/edx.svg',
  'Educative': 'lib/assets/logos/educative.svg',
  'Frontend Masters': 'lib/assets/logos/frontend_masters.svg',
  'Scrimba': 'lib/assets/logos/scrimba.svg',
  'DataCamp': 'lib/assets/logos/datacamp.svg',
  'Codecademy': 'lib/assets/logos/codecademy.svg',
  'Codédex': 'lib/assets/logos/codex.svg',
  'LinkedIn Learning': 'lib/assets/logos/linkedin.svg',
  'Microsoft Learn': 'lib/assets/logos/microsoft.svg',
  'AWS Skill Builder': 'lib/assets/logos/aws.svg',
  'Google Skillshop': 'lib/assets/logos/google_skillshop.svg',
  'Interview Cake': 'lib/assets/logos/interview_cake.svg',
  'AlgoExpert': 'lib/assets/logos/algoexpert.svg',
  'LeetCode': 'lib/assets/logos/leetcode.svg',
  'Overleaf': 'lib/assets/logos/overleaf.svg',

  // Productivity & Notes
  'Notion': 'lib/assets/logos/notion.svg',
  'Microsoft 365': 'lib/assets/logos/microsoft.svg',
  'Google Workspace': 'lib/assets/logos/google_workspace.svg',
  'Airtable': 'lib/assets/logos/airtable.svg',
  'Asana': 'lib/assets/logos/asana.svg',
  'Monday.com': 'lib/assets/logos/monday.svg',
  'Slack': 'lib/assets/logos/slack.svg',
  'Discord': 'lib/assets/logos/discord.svg',
  'Zoom': 'lib/assets/logos/zoom.svg',
  'Grammarly': 'lib/assets/logos/grammarly.svg',
  'Evernote': 'lib/assets/logos/evernote.svg',
  'Typeform': 'lib/assets/logos/typeform.svg',
  'Prezi': 'lib/assets/logos/prezi.svg',
  'Miro': 'lib/assets/logos/miro.svg',
  'Obsidian': 'lib/assets/logos/obsidian.svg',
  'Reclaim.ai': 'lib/assets/logos/reclaim.svg',

  // Hardware & Student Discounts
  'Apple': 'lib/assets/logos/apple.svg',
  'Dell': 'lib/assets/logos/dell.svg',
  'Lenovo': 'lib/assets/logos/lenova.svg',
  'HP': 'lib/assets/logos/hp.svg',
  'Microsoft': 'lib/assets/logos/microsoft.svg',
  'Samsung': 'lib/assets/logos/samsung.svg',
  'Logitech': 'lib/assets/logos/logitech.svg',
  'Bose': 'lib/assets/logos/bose.svg',
  'Sony': 'lib/assets/logos/sony.svg',
  'Best Buy': 'lib/assets/logos/best_buy.svg',
  'OnTheHub': 'lib/assets/logos/onthehub.svg',

  // Institutional & Faculty Perks
  'AWS Academy': 'lib/assets/logos/aws.svg',
  'Oracle Academy': 'lib/assets/logos/oracle.svg',
  'Slack for Education': 'lib/assets/logos/slack.svg',
  'Coursera for Campus': 'lib/assets/logos/coursera.svg',
  'IBM Academic Initiative': 'lib/assets/logos/ibm.svg',
  'VMware IT Academy': 'lib/assets/logos/vmware_it.svg',
  'Cisco Networking Academy': 'lib/assets/logos/cisco.svg',
  'cPanel': 'lib/assets/logos/cpanel.svg',

  // Entertainment & Lifestyle
  'Spotify': 'lib/assets/logos/spotify.svg',
  'Apple Music': 'lib/assets/logos/apple.svg',
  'YouTube Premium': 'lib/assets/logos/youtube.svg',
  'Amazon Prime': 'lib/assets/logos/amazon_prime.svg',
  'Paramount+': 'lib/assets/logos/paramount.svg',
  'Peacock': 'lib/assets/logos/peacock.svg',
  'Hulu': 'lib/assets/logos/hulu.svg',
  'Headspace': 'lib/assets/logos/headspace.svg',
  'Calm': 'lib/assets/logos/calm.svg',
  'YNAB': 'lib/assets/logos/ynab.svg',
  'The New York Times': 'lib/assets/logos/newyork.svg',
  'Washington Post': 'lib/assets/logos/washington.svg',
  'Wall Street Journal': 'lib/assets/logos/wall_street.svg',
  'UNiDAYS': 'lib/assets/logos/unidays.svg',
  'Student Beans': 'lib/assets/logos/student_beans.svg',
};

const _f = PerkType.free;
const _c = PerkType.credit;
const _d = PerkType.discount;
const _t = PerkType.trial;


// DATA (10 categories)

const List<PerkCategory> perkCategories = [
  // ---------------- CLOUD ----------------
  PerkCategory(
    title: 'Cloud & Infrastructure',
    shortTitle: 'Cloud',
    blurb: 'Hosting, domains, databases and serverless',
    icon: Icons.cloud_outlined,
    color: Color(0xFF0284C7),
    tint: Color(0xFFE0F2FE),
    perks: [
      Perk('Azure for Students', 'Microsoft Cloud', '\$100 Credit + 25+ Free Services', _c, 'Student (Email)', 'https://azure.microsoft.com/free/students'),
      Perk('DigitalOcean', 'Cloud VPS', '\$200 Credit (1 Year)', _c, 'Student (GitHub Pack)', 'https://education.github.com/pack'),
      Perk('AWS Educate', 'Amazon Cloud', '\$50-\$100 Credits (Varies)', _c, 'Student (Email)', 'https://aws.amazon.com/education/awseducate/'),
      Perk('Google Cloud', 'GCP Platform', '\$300 Credit + Always-Free Tier', _c, 'Open to All', 'https://cloud.google.com/free'),
      Perk('IBM Cloud', 'Enterprise Cloud', '\$200 First Month + 40+ Free Services', _c, 'Student (Email)', 'https://www.ibm.com/cloud/free'),
      Perk('Oracle Cloud', 'Cloud Infrastructure', '\$300 Trial + Always-Free VMs', _c, 'Open to All', 'https://www.oracle.com/cloud/free/'),
      Perk('Heroku', 'PaaS Deployment', '\$13/mo Credit (2 Years)', _c, 'Student (GitHub Pack)', 'https://www.heroku.com/github-students'),
      Perk('Vercel', 'Frontend Hosting', 'Hobby Plan (Free Forever)', _f, 'Open to All', 'https://vercel.com/pricing'),
      Perk('Netlify', 'Jamstack Hosting', 'Pro Plan (Open Source)', _f, 'Open Source', 'https://opensource-form.netlify.com/'),
      Perk('Railway', 'App Deployment', '\$5 Trial Credit', _t, 'Open to All', 'https://railway.app/pricing'),
      Perk('Render', 'Cloud Hosting', 'Free Tier', _f, 'Open to All', 'https://render.com/pricing'),
      Perk('Namecheap', 'Domains & SSL', '1 Free .me Domain + SSL', _f, 'Student (GitHub Pack)', 'https://nc.me/'),
      Perk('Name.com', 'Domains', '1 Free Domain (.dev, .app)', _f, 'Student (GitHub Pack)', 'https://www.name.com/partner/github-students'),
      Perk('MongoDB Atlas', 'NoSQL Database', '\$50 Credits + Free Cluster', _c, 'Student (GitHub Pack)', 'https://www.mongodb.com/students'),
      Perk('PlanetScale', 'MySQL Database', 'Free Hobby Tier', _f, 'Open to All', 'https://planetscale.com/'),
      Perk('Supabase', 'PostgreSQL Backend', 'Free Tier', _f, 'Open to All', 'https://supabase.com/'),
      Perk('Cloudflare', 'CDN & Security', 'Free Plan + Education Program', _f, 'Student', 'https://www.cloudflare.com/en-gb/students/'),
      Perk('.TECH Domain', 'Domain Registrar', '1 Free .tech Domain', _f, 'Student (GitHub Pack)', 'https://get.tech/github-student-developer-pack'),
    ],
  ),

  // ---------------- DEV TOOLS ----------------
  PerkCategory(
    title: 'Developer Tools & IDEs',
    shortTitle: 'Dev Tools',
    blurb: 'IDEs, Git clients, API tools and platforms',
    icon: Icons.code_rounded,
    color: Color(0xFF4F46E5),
    tint: Color(0xFFE9E9FF),
    perks: [
      Perk('GitHub Student Pack', 'The "Holy Grail"', 'Copilot + Pro Plan + 100+ Partners', _f, 'Student (ID/Proof)', 'https://education.github.com/pack'),
      Perk('JetBrains', 'IDE Suite', 'All Products Free (IntelliJ, PyCharm, etc.)', _f, 'Student (Email/ISIC)', 'https://www.jetbrains.com/community/education/#students'),
      Perk('Visual Studio', 'Microsoft IDE', 'Professional/Enterprise Features', _f, 'Student (Email)', 'https://visualstudio.microsoft.com/students/'),
      Perk('GitKraken', 'Git GUI Client', 'Pro License', _f, 'Student (GitHub Pack)', 'https://www.gitkraken.com/github-student-developer-pack-bundle'),
      Perk('GitLens Pro', 'VS Code Git Extension', 'Pro Features', _f, 'Student (GitHub Pack)', 'https://www.gitkraken.com/gitlens'),
      Perk('Tower', 'Git Client (Mac/Win)', 'Pro License', _f, 'Student (Email)', 'https://www.git-tower.com/students'),
      Perk('Termius', 'SSH/SFTP Client', 'Premium (Mobile/Desktop)', _f, 'Student (GitHub Pack)', 'https://termius.com/education'),
      Perk('Postman', 'API Platform', 'Pro Features', _f, 'Student', 'https://www.postman.com/student-program/'),
      Perk('Insomnia', 'API Client', 'Free Plan', _f, 'Open to All', 'https://insomnia.rest/'),
      Perk('Polypane', 'Dev Browser', 'Student License', _f, 'Student (GitHub Pack)', 'https://polypane.app/github-students/'),
      Perk('Replit', 'Online IDE', '\$15/mo Off (6 Months)', _d, 'Student (Email)', 'https://replit.com/pricing'),
      Perk('CodeSandbox', 'Online IDE', 'Pro Features', _d, 'Student', 'https://codesandbox.io/docs/learn/plans/education-plans'),
      Perk('Bootstrap Studio', 'Web Design Tool', 'License', _f, 'Student (GitHub Pack)', 'https://bootstrapstudio.io/pages/student-license'),
      Perk('Unity', 'Game Engine', 'Student Plan', _f, 'Student (SheerID)', 'https://unity.com/products/unity-student'),
      Perk('Unreal Engine', 'Game Engine', 'Full Access', _f, 'Open to All', 'https://www.unrealengine.com/'),
      Perk('Navicat', 'DB Admin Tool', '1 Year License', _f, 'Student (ID Scan)', 'https://www.navicat.com/en/sponsorship/education/student'),
      Perk('PopSQL', 'SQL Editor', 'Premium Plan', _f, 'Student (GitHub Pack)', 'https://popsql.com/github-students'),
      Perk('Working Copy', 'iOS Git Client', 'Pro Features', _f, 'Student (Email)', 'https://workingcopy.app/education/'),
      Perk('Sentry', 'Error Monitoring', '500K Events/Month', _f, 'Student', 'https://sentry.io/for/education/'),
      Perk('Codecov', 'Code Coverage', 'Free for Students', _f, 'Student', 'https://about.codecov.io/for/education/'),
      Perk('DeepSource', 'Static Analysis', 'Free for Students', _f, 'Student', 'https://deepsource.com/blog/deepsource-gh-education'),
      Perk('VMware Workstation', 'Virtualization', 'Pro Edition', _f, 'Open to All', 'https://blogs.vmware.com/cloud-foundation/2025/03/10/vmware-fusion-workstation-going-free-new-resources/'),
      Perk('Cursor', 'AI-Powered IDE', 'Education Partner Program', _f, 'Student (Application)', 'https://cursor.com/students'),
      Perk('Lovable', 'AI App Builder', '50% Off Pro', _d, 'Student (SheerID)', 'https://lovable.dev/students'),
      Perk('FlutterFlow', 'Low-Code Builder', '1 Year Free Pro', _f, 'Student (Application)', 'https://flutterflow.typeform.com/to/VEA2GRZa'),
      Perk('n8n', 'Workflow Automation', 'Self-Hosted (Open Source)', _f, 'Open to All', 'https://n8n.io/'),
      Perk('Antigravity', 'AI IDE', 'Full Access', _f, 'Open to All', 'https://antigravity.dev/'),
      Perk('v0.app', 'AI UI Generator', '1 Year Premium', _f, 'Student (Verified)', 'https://v0.dev/students'),
    ],
  ),

  // ---------------- SECURITY ----------------
  PerkCategory(
    title: 'Security & Cybersecurity',
    shortTitle: 'Security',
    blurb: 'Pentest labs, CTFs, password managers and VPNs',
    icon: Icons.shield_outlined,
    color: Color(0xFFB91C1C),
    tint: Color(0xFFFEE2E2),
    perks: [
      Perk('1Password', 'Password Manager', '1 Year Free', _f, 'Student (GitHub Pack)', 'https://1password.com/developers/students'),
      Perk('Bitwarden', 'Password Manager', 'Free Plan', _f, 'Open to All', 'https://bitwarden.com/'),
      Perk('Dashlane', 'Password Manager', '6 Months Premium', _f, 'Student', 'https://www.dashlane.com/students'),
      Perk('HackTheBox', 'Pentesting Labs', 'Student Rate Subscription', _d, 'Student (.edu Email)', 'https://help.hackthebox.com/en/articles/7973133-getting-the-student-subscription'),
      Perk('TryHackMe', 'Cyber Training', '20% Off Premium', _d, 'Student (Email)', 'https://help.tryhackme.com/en/articles/6494960-student-discount'),
      Perk('PentesterLab', 'Web Security Labs', 'Student Discount', _d, 'Student', 'https://pentesterlab.com/'),
      Perk('Shodan', 'IoT Search Engine', 'Membership Upgrade', _f, 'Student (.edu Email)', 'https://help.shodan.io/the-basics/academic-upgrade'),
      Perk('Maltego', 'OSINT Graphing', 'Basic Plan', _f, 'Open to All', 'https://www.maltego.com/maltego-community/'),
      Perk('Nessus', 'Vulnerability Scanner', 'Education License', _f, 'Student/Instructor (Verified)', 'https://www.tenable.com/tenable-nessus-for-education'),
      Perk('Cryptohack', 'Cryptography Labs', 'Education Access', _f, 'Open to All', 'https://cryptohack.org/'),
      Perk('OverTheWire', 'Wargames', 'Free Access', _f, 'Open to All', 'https://overthewire.org/'),
      Perk('PicoCTF', 'CTF Platform', 'Free Practice', _f, 'Open to All', 'https://picoctf.org/'),
      Perk('Surfshark', 'VPN Service', '~80% Off', _d, 'Student', 'https://surfshark.com/student-discount'),
      Perk('NordVPN', 'VPN Service', 'Student Discount', _d, 'Student', 'https://nordvpn.com/student-discount/'),
      Perk('Snyk', 'Security Scanning', 'Free Plan', _f, 'Open to All', 'https://snyk.io/'),
    ],
  ),

  // ---------------- DESIGN ----------------
  PerkCategory(
    title: 'Design & Creative',
    shortTitle: 'Design',
    blurb: 'UI/UX, graphics, 3D, video and creative assets',
    icon: Icons.palette_outlined,
    color: Color(0xFFBE185D),
    tint: Color(0xFFFDE8F3),
    perks: [
      Perk('Figma', 'UI/UX Design', 'Professional Plan Free', _f, 'Student (Verification)', 'https://www.figma.com/education/'),
      Perk('Canva', 'Graphic Design', 'Pro Features', _f, 'Student (GitHub Pack)', 'https://www.canva.com/education/'),
      Perk('Adobe CC', 'Creative Cloud', '~60% Off All Apps', _d, 'Student (ID/Email)', 'https://www.adobe.com/creativecloud/buy/students.html'),
      Perk('Autodesk', '3D/CAD Software', 'Maya, AutoCAD, etc. (1 Year)', _f, 'Student (SheerID)', 'https://www.autodesk.com/education/edu-software/overview'),
      Perk('Blender', '3D Modeling', 'Full Access', _f, 'Open to All', 'https://www.blender.org/'),
      Perk('Sketch', 'Mac UI Design', 'Free License', _f, 'Student (ID Scan)', 'https://www.sketch.com/education/'),
      Perk('Framer', 'Website Builder', 'Pro Access', _f, 'Student (Verification)', 'https://www.framer.com/education/'),
      Perk('Webflow', 'Web Design', 'CMS Site Plan', _f, 'Student (Email)', 'https://webflow.com/for/classroom'),
      Perk('Icons8', 'Design Assets', '3 Months Full Access', _f, 'Student (GitHub Pack)', 'https://icons8.com/github-students'),
      Perk('IconScout', 'Icons & Lottie', '1 Year Pro Plan', _f, 'Student (GitHub Pack)', 'https://iconscout.com/github-students'),
      Perk('DaVinci Resolve', 'Video Editor', 'Full Version', _f, 'Open to All', 'https://www.blackmagicdesign.com/products/davinciresolve'),
      Perk('Descript', 'Audio/Video Editor', 'Education Discount', _d, 'Student/Educator', 'https://help.descript.com/hc/en-us/articles/10255872422029-Non-Profit-and-Education-subscription'),
      Perk('ThemeIsle', 'WordPress Themes', '1 Year Neve Pro', _f, 'Student (GitHub Pack)', 'https://themeisle.com/github-students/'),
    ],
  ),

  // ---------------- AI & DATA ----------------
  PerkCategory(
    title: 'AI & Data Science',
    shortTitle: 'AI & Data',
    blurb: 'AI tools, ML platforms and analytics software',
    icon: Icons.psychology_outlined,
    color: Color(0xFF7E22CE),
    tint: Color(0xFFF3E8FF),
    perks: [
      Perk('GitHub Copilot', 'AI Coding Assistant', 'Full Access', _f, 'Student (GitHub Pack)', 'https://education.github.com/pack'),
      Perk('Google Gemini', 'AI Assistant', '1 Year Pro Trial', _t, 'Student (Verified)', 'https://gemini.google/students/'),
      Perk('Perplexity Pro', 'AI Search Engine', '3 Months Education', _f, 'Student (Verified)', 'https://www.perplexity.ai/academic'),
      Perk('OpenAI API', 'GPT/DALL-E/Whisper', 'Free Credits (Region Varies)', _c, 'Open to All', 'https://openai.com/'),
      Perk('Google Colab', 'Python Notebooks', 'Free GPUs', _f, 'Open to All', 'https://colab.research.google.com/'),
      Perk('Kaggle', 'ML Competitions', 'Free GPUs/TPUs', _f, 'Open to All', 'https://www.kaggle.com/'),
      Perk('HuggingFace', 'ML Models', 'Free GPU Hours', _f, 'Open to All', 'https://huggingface.co/'),
      Perk('Tableau', 'Data Visualization', 'Desktop + Prep Builder', _f, 'Student (SheerID)', 'https://www.tableau.com/academic/students'),
      Perk('MATLAB', 'Technical Computing', 'Student License', _d, 'Student', 'https://www.mathworks.com/products/matlab/student.html'),
      Perk('Deepnote', 'Data Notebooks', 'Pro Team Plan', _f, 'Student', 'https://deepnote.com/education'),
      Perk('Wolfram|Alpha', 'Computational Engine', 'Pro Features', _d, 'Student', 'https://www.wolframalpha.com/pro/pricing/students'),
      Perk('SQLGate', 'SQL IDE', 'Standard Subscription', _f, 'Student (GitHub Pack)', 'https://www.sqlgate.com/student-pack'),
      Perk('ChatGPT Plus', 'AI Assistant', '50% Off (\$10/mo)', _d, 'Student (SheerID, US/CA)', 'https://help.openai.com/en/articles/10968654-student-discounts-for-chatgpt-plus-uscanada'),
      Perk('HyperWrite', 'AI Writing Assistant', '50% Off Premium', _d, 'Student (.edu Email)', 'https://www.hyperwriteai.com/faq/does-hyperwrite-offer-a-student-discount'),
      Perk('Julius AI', 'Data Analysis AI', 'Education Discount', _d, 'Student', 'https://julius.ai/docs/account/discounts'),
    ],
  ),

  // ---------------- LEARNING ----------------
  PerkCategory(
    title: 'Learning Platforms',
    shortTitle: 'Learning',
    blurb: 'Courses, coding practice and certifications',
    icon: Icons.school_outlined,
    color: Color(0xFF0E7490),
    tint: Color(0xFFE6FBFD),
    perks: [
      Perk('Coursera', 'Online Courses', 'Financial Aid + Free Audits', _f, 'Application', 'https://www.coursera.support/s/article/learner-000001455'),
      Perk('edX', 'University Courses', 'Free Audit Track', _f, 'Open to All', 'https://www.edx.org/'),
      Perk('Educative', 'Interactive Courses', '6 Months Free', _f, 'Student (GitHub Pack)', 'https://www.educative.io/github-students'),
      Perk('Frontend Masters', 'Web Dev Courses', '6 Months Free', _f, 'Student (GitHub Pack)', 'https://frontendmasters.com/welcome/github-student-developers/'),
      Perk('Scrimba', 'Frontend Courses', 'Pro Discount', _d, 'Student', 'https://scrimba.helpscoutdocs.com/article/19-do-you-offer-student-discounts'),
      Perk('DataCamp', 'Data Science Courses', '3 Months Free', _f, 'Student (GitHub Pack)', 'https://www.datacamp.com/github-students'),
      Perk('Codecademy', 'Coding Courses', '35% Off Pro', _d, 'Student', 'https://www.codecademy.com/student-center'),
      Perk('Codédex', 'Learn to Code', 'Education Plan', _f, 'Student (GitHub Pack)', 'https://www.codedex.io/github-students'),
      Perk('LinkedIn Learning', 'Professional Skills', 'Free via Library', _f, 'Library Card', 'https://www.linkedin.com/learning/'),
      Perk('Microsoft Learn', 'MS Technologies', 'Free + Cert Vouchers', _f, 'Open to All', 'https://learn.microsoft.com/'),
      Perk('AWS Skill Builder', 'AWS Training', 'Free Tier', _f, 'Open to All', 'https://skillbuilder.aws/'),
      Perk('Google Skillshop', 'Google Products', 'Free Certifications', _f, 'Open to All', 'https://skillshop.withgoogle.com/'),
      Perk('Interview Cake', 'Interview Prep', '3 Weeks Free', _f, 'Student (GitHub Pack)', 'https://www.interviewcake.com/github-students'),
      Perk('AlgoExpert', 'Interview Prep', 'Student Discount', _d, 'Student (GitHub Pack)', 'https://www.algoexpert.io/github-students'),
      Perk('LeetCode', 'Coding Practice', 'Premium Discount', _d, 'Student', 'https://leetcode.com/student/'),
      Perk('Overleaf', 'LaTeX Editor', 'Premium Features', _f, 'Student (Email)', 'https://www.overleaf.com/user/subscription/plans?plan=student&period=annual'),
    ],
  ),

  // ---------------- PRODUCTIVITY ----------------
  PerkCategory(
    title: 'Productivity & Collaboration',
    shortTitle: 'Productivity',
    blurb: 'Notes, tasks, office suites and team tools',
    icon: Icons.bolt_rounded,
    color: Color(0xFFD97706),
    tint: Color(0xFFFEF3C7),
    perks: [
      Perk('Notion', 'Workspace/Wiki', 'Plus Plan Free', _f, 'Student (Email)', 'https://www.notion.com/product/notion-for-education'),
      Perk('Microsoft 365', 'Office Suite', 'Full Office Apps', _f, 'Student (School Must Join)', 'https://www.microsoft.com/en-us/education/products/office'),
      Perk('Google Workspace', 'Productivity Suite', 'Full Access via School', _f, 'Student (School Must Join)', 'https://edu.google.com/'),
      Perk('Airtable', 'Database/Spreadsheet', 'Education Plan', _f, 'Student/Nonprofit', 'https://support.airtable.com/docs/nonprofit-and-educational-plans-faqs'),
      Perk('Asana', 'Project Management', 'Student Plan', _f, 'Student', 'https://asana.com/industry/students'),
      Perk('Monday.com', 'Work Management', 'Free Plan', _f, 'Open to All', 'https://monday.com/pricing'),
      Perk('Slack', 'Team Messaging', 'Free Tier + Education', _f, 'Student', 'https://slack.com/'),
      Perk('Discord', 'Communication', 'Free + Nitro Promos', _f, 'Open to All', 'https://discord.com/'),
      Perk('Zoom', 'Video Conferencing', 'Free + School Plans', _f, 'Open to All', 'https://zoom.us/'),
      Perk('Grammarly', 'Writing Assistant', 'Premium Discount', _d, 'Student', 'https://www.grammarly.com/edu'),
      Perk('Evernote', 'Note Taking', '50% Off Personal', _d, 'Student', 'https://evernote.com/students'),
      Perk('Typeform', 'Forms & Surveys', 'Student Discount', _d, 'Student', 'https://help.typeform.com/hc/en-us/articles/360039728951-Non-profit-NGO-and-student-discounts-at-Typeform'),
      Perk('Prezi', 'Presentations', 'Edu Account', _f, 'Student (Email)', 'https://prezi.com/education/'),
      Perk('Miro', 'Whiteboarding', 'Education Plan', _f, 'Student (Email)', 'https://miro.com/education-whiteboard/'),
      Perk('Obsidian', 'Note-Taking', '40% Off Sync/Publish', _d, 'Student (Verification)', 'https://help.obsidian.md/discounts'),
      Perk('Reclaim.ai', 'Calendar AI', '50% Off (12 Months)', _d, 'Student (Verification)', 'https://reclaim.ai/pricing/education-discount'),
    ],
  ),

  // ---------------- HARDWARE ----------------
  PerkCategory(
    title: 'Hardware & Electronics',
    shortTitle: 'Hardware',
    blurb: 'Laptops, tablets and accessories at student prices',
    icon: Icons.devices_rounded,
    color: Color(0xFF334155),
    tint: Color(0xFFF1F5F9),
    perks: [
      Perk('Apple', 'Mac/iPad', '~10% Off + Free AirPods (Seasonal)', _d, 'Student (Education Store)', 'https://www.apple.com/shop/education-pricing'),
      Perk('Dell', 'Laptops/Desktops', 'Up to 20% Off', _d, 'Student (Email)', 'https://www.dell.com/en-us/lp/students'),
      Perk('Lenovo', 'ThinkPad/IdeaPad', '5-60% Off', _d, 'Student (ID.me)', 'https://www.lenovo.com/us/en/student/'),
      Perk('HP', 'Laptops/Desktops', 'Up to 35% Off', _d, 'Student (UNiDAYS)', 'https://www.hp.com/us-en/shop/cv/hp-education'),
      Perk('Microsoft', 'Surface Devices', 'Up to 10% Off', _d, 'Student (Email)', 'https://www.microsoft.com/en-us/store/b/education'),
      Perk('Samsung', 'Electronics', 'Student Discounts', _d, 'Student (Email)', 'https://www.samsung.com/us/shop/offer-program/education/'),
      Perk('Logitech', 'Accessories', '25% Off', _d, 'Student (UNiDAYS)', 'https://www.logitech.com/en-us/education.html'),
      Perk('Bose', 'Audio', 'Student Discount', _d, 'Student (ID.me)', 'https://www.bose.com/idme-group-discounts-program'),
      Perk('Sony', 'Electronics', 'Education Pricing', _d, 'Student (ID.me)', 'https://electronics.sony.com/group-offers'),
      Perk('Best Buy', 'Electronics', 'Student Deals Hub', _d, 'Student (Email)', 'https://www.bestbuy.com/site/misc/back-to-school/pcmcat334100050000.c'),
      Perk('OnTheHub', 'Software/Hardware', 'School-Sponsored Deals', _d, 'Student (School)', 'https://onthehub.com/shop?userGroup=students'),
    ],
  ),

  // ---------------- INSTITUTIONAL ----------------
  PerkCategory(
    title: 'Institutional Access',
    shortTitle: 'Institutional',
    blurb: 'Faculty or admin must register your institution first',
    icon: Icons.account_balance_outlined,
    color: Color(0xFF047857),
    tint: Color(0xFFE6FBF3),
    facultyOnly: true,
    perks: [
      Perk('AWS Academy', 'Cloud Learning', '50% Off Certs + Large Sandbox', _c, 'Faculty Must Invite', 'https://aws.amazon.com/training/awsacademy/'),
      Perk('Oracle Academy', 'Database/Java', 'Full Courseware + Cloud Tier', _f, 'Institution Reg', 'https://academy.oracle.com/'),
      Perk('GitHub Campus', 'GitHub Enterprise', 'School-Wide Access', _f, 'Admin Reg', 'https://education.github.com/schools'),
      Perk('Slack for Education', 'Team Messaging', '85% Off or Free (Pro)', _d, 'Faculty App', 'https://slack.com/help/articles/206646877'),
      Perk('Coursera for Campus', 'Online Courses', 'Full Catalog Access', _f, 'Institution Reg', 'https://www.coursera.org/campus'),
      Perk('IBM Academic Initiative', 'Cloud/AI/ML', 'Free Tools & Platforms', _f, 'Faculty Reg', 'https://www.ibm.com/academic'),
      Perk('VMware IT Academy', 'Virtualization', 'Licensed Software', _f, 'Institution Reg', 'https://www.vmware.com/resources/compatibility/sim/interop_matrix.php'),
      Perk('Cisco Networking Academy', 'Networking', 'Full Courseware', _f, 'Institution Reg', 'https://www.netacad.com/'),
      Perk('cPanel', 'Web Hosting Panel', 'Education License', _f, 'Institution App', 'https://input.cpanel.net/s3/edu'),
    ],
  ),

  // ---------------- ENTERTAINMENT ----------------
  PerkCategory(
    title: 'Entertainment & Lifestyle',
    shortTitle: 'Lifestyle',
    blurb: 'Streaming, music, wellness and everyday perks',
    icon: Icons.theaters_outlined,
    color: Color(0xFFEA580C),
    tint: Color(0xFFFFEDD5),
    perks: [
      Perk('Spotify', 'Music Streaming', '~50% Off + Hulu (US)', _d, 'Student (SheerID)', 'https://www.spotify.com/us/student/'),
      Perk('Apple Music', 'Music Streaming', '~50% Off + Free Apple TV+', _d, 'Student (UNiDAYS)', 'https://www.apple.com/apple-music/'),
      Perk('YouTube Premium', 'Ad-Free Video', '~40-50% Off', _d, 'Student (SheerID)', 'https://www.youtube.com/premium/student'),
      Perk('Amazon Prime', 'Shopping/Video', '6 Months Free + 50% Off', _t, 'Student (Email)', 'https://www.amazon.com/prime/student'),
      Perk('Paramount+', 'Streaming', 'Up to 50% Off', _d, 'Student (SheerID)', 'https://www.paramountplus.com/account/signup/edu-offer/'),
      Perk('Peacock', 'Streaming', '60% Off (~\$2.99/mo)', _d, 'Student', 'https://www.peacocktv.com/student'),
      Perk('Hulu', 'Streaming', '\$1.99/mo Student Plan', _d, 'Student (SheerID)', 'https://www.hulu.com/student'),
      Perk('Headspace', 'Meditation', '\$9.99/year', _d, 'Student (SheerID)', 'https://www.headspace.com/studentplan'),
      Perk('Calm', 'Meditation', 'Education Plan', _f, 'Student (Email)', 'https://www.calm.com/c/education'),
      Perk('YNAB', 'Budgeting', '1 Year Free', _f, 'Student (Email)', 'https://www.ynab.com/college'),
      Perk('The New York Times', 'News', 'Free/Discounted', _d, 'Student (.edu Email)', 'https://www.nytimes.com/activate-access/edu-access'),
      Perk('Washington Post', 'News', 'Discounted Access', _d, 'Student (.edu Email)', 'https://subscribe.washingtonpost.com/acquisition/?p=s_v_edu'),
      Perk('Wall Street Journal', 'News', '\$4/month', _d, 'Student', 'https://education.wsj.com/'),
      Perk('UNiDAYS', 'Discount Platform', 'Aggregated Student Deals', _f, 'Student (Verification)', 'https://www.myunidays.com/'),
      Perk('Student Beans', 'Discount Platform', 'Aggregated Student Deals', _f, 'Student (Verification)', 'https://www.studentbeans.com/'),
    ],
  ),
];

int get totalPerks =>
    perkCategories.fold(0, (total, c) => total + c.perks.length);