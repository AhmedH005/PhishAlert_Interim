import '../models/message_item.dart';

/// The bundled starter dataset for the interim prototype: 12 hand-written
/// messages spread across 7 levels (easy → medium). It is a small starter set
/// that will grow in later sprints. The messages are stored on-device and in
/// memory only; there is no backend yet.
final List<MessageItem> sampleMessages = [
  MessageItem.contentPack(
    id: 'L1Q1',
    levelNumber: 1,
    difficulty: 'easy',
    channel: 'email',
    sender: 'security-alert@bank-verification-now.com',
    subject: 'Urgent: Your bank account has been locked',
    content:
        'We noticed suspicious activity on your account. Click here immediately to verify your details and restore access.',
    label: 'phish',
    hint: 'Check the urgency and the sender domain.',
    explanation:
        'Phishing — it creates panic and pushes you to click immediately, and the sender domain is not a trusted banking domain.',
    cues: [
      'Click here immediately',
      'suspicious activity',
      'untrusted sender domain',
    ],
    takeawayTip: 'Urgency is one of the most common phishing tactics.',
  ),
  MessageItem.contentPack(
    id: 'L1Q2',
    levelNumber: 1,
    difficulty: 'easy',
    channel: 'email',
    sender: 'auto-confirm@amazon.co.uk',
    subject: 'Your order has been shipped',
    content:
        'Your recent order has been dispatched and is on its way. Track your parcel through your Amazon account.',
    label: 'legit',
    hint: 'Does it ask for unusual action or sensitive data?',
    explanation:
        'Legitimate — it is informational, applies no pressure, and points you back to your own account rather than asking for sensitive input.',
    cues: ['informational tone', 'no pressure', 'normal account reference'],
    takeawayTip: 'Legitimate messages often inform rather than pressure.',
  ),
  MessageItem.contentPack(
    id: 'L2Q1',
    levelNumber: 2,
    difficulty: 'easy',
    channel: 'email',
    sender: 'it-helpdesk@company-reset.com',
    subject: 'Your password expires today',
    content:
        'Your password expires today. To avoid losing access, confirm your login details using the secure form below.',
    label: 'phish',
    hint:
        'Real password resets do not ask you to send your current login details.',
    explanation:
        'Phishing — it asks for login details directly and uses urgency to push you into acting quickly.',
    cues: ['expires today', 'confirm your login details', 'pressure language'],
    takeawayTip: 'Never provide passwords in response to email prompts.',
  ),
  MessageItem.contentPack(
    id: 'L2Q2',
    levelNumber: 2,
    difficulty: 'easy',
    channel: 'email',
    sender: 'noreply@westminster.ac.uk',
    subject: 'Semester timetable update',
    content:
        'Your semester timetable has been updated. Please log in to the student portal to review the revised schedule.',
    label: 'legit',
    hint: 'Look at the domain and action requested.',
    explanation:
        'Legitimate — the domain matches the institution and it directs you to the known portal rather than asking for details by email.',
    cues: ['trusted academic domain', 'portal login', 'no credential request'],
    takeawayTip: 'Trusted domains and normal workflows are reassuring signals.',
  ),
  MessageItem.contentPack(
    id: 'L3Q1',
    levelNumber: 3,
    difficulty: 'easy',
    channel: 'sms',
    sender: 'Unknown Number',
    subject: '',
    content:
        'Congratulations! You have won a £500 gift card. Claim it now at gift-reward-fast.net before midnight.',
    label: 'phish',
    hint: 'Unexpected prizes are a classic scam signal.',
    explanation:
        'Phishing — it promises an unexpected reward, creates urgency, and sends you to a suspicious external website.',
    cues: ['won a £500 gift card', 'before midnight', 'gift-reward-fast.net'],
    takeawayTip: 'Unexpected rewards should always be treated with suspicion.',
  ),
  MessageItem.contentPack(
    id: 'L3Q2',
    levelNumber: 3,
    difficulty: 'easy',
    channel: 'sms',
    sender: 'YourBank',
    subject: '',
    content:
        'Your one-time verification code is 482193. Do not share this code with anyone.',
    label: 'legit',
    hint: 'Does the message ask you to click or reply with secrets?',
    explanation:
        'Legitimate — it only provides a code and warns against sharing it, with no suspicious link or credential request.',
    cues: ['one-time code', 'Do not share', 'no suspicious link'],
    takeawayTip:
        'A normal OTP message usually contains only the code and a warning.',
  ),
  MessageItem.contentPack(
    id: 'L4Q1',
    levelNumber: 4,
    difficulty: 'easy',
    channel: 'email',
    sender: 'refunds@hmrc-tax-support.com',
    subject: 'You are eligible for a tax refund',
    content:
        'You are owed a tax refund. Complete the attached form today to receive payment within 24 hours.',
    label: 'phish',
    hint: 'Check whether the sender matches the real organisation.',
    explanation:
        'Phishing — it imitates a government service using a misleading domain and pushes you to submit data quickly.',
    cues: [
      'owed a tax refund',
      'within 24 hours',
      'misleading government-style domain',
    ],
    takeawayTip: 'Scammers often imitate trusted public institutions.',
  ),
  MessageItem.contentPack(
    id: 'L5Q1',
    levelNumber: 5,
    difficulty: 'easy',
    channel: 'sms',
    sender: 'ParcelTeam',
    subject: '',
    content:
        'We missed your package delivery. Rearrange now at parcel-fix-track.info to avoid return to sender.',
    label: 'phish',
    hint: 'Watch for pressure and suspicious tracking links.',
    explanation:
        'Phishing — it creates urgency and sends you to an unfamiliar external website.',
    cues: ['Rearrange now', 'avoid return to sender', 'parcel-fix-track.info'],
    takeawayTip:
        'Delivery scams often push users to act fast through fake tracking sites.',
  ),
  MessageItem.contentPack(
    id: 'L5Q2',
    levelNumber: 5,
    difficulty: 'easy',
    channel: 'email',
    sender: 'info@spotify.com',
    subject: 'Your subscription renews tomorrow',
    content:
        'Your subscription will renew tomorrow using your saved payment method. Manage your plan in the Spotify app or account page.',
    label: 'legit',
    hint: 'Does it push you to an unknown link or request sensitive data?',
    explanation:
        'Legitimate — it is informational, uses a trusted sender, and refers you back to the known app or account page.',
    cues: ['renewal notice', 'trusted sender', 'known app/account'],
    takeawayTip:
        'Legitimate services usually direct users back to official apps or dashboards.',
  ),
  MessageItem.contentPack(
    id: 'L6Q1',
    levelNumber: 6,
    difficulty: 'medium',
    channel: 'email',
    sender: 'account-security@micr0soft-support.com',
    subject: 'Unusual sign-in detected',
    content:
        'We noticed a sign-in from a new device. If this was not you, review activity immediately using the link below.',
    label: 'phish',
    hint: 'The brand name may look correct at first glance. Check closely.',
    explanation:
        'Phishing — the domain imitates Microsoft using a zero in place of the letter o. Brand spoofing is common in more convincing scams.',
    cues: ['micr0soft', 'review activity immediately', 'brand impersonation'],
    takeawayTip:
        'Some phishing attacks rely on tiny visual changes in domains.',
  ),
  MessageItem.contentPack(
    id: 'L6Q2',
    levelNumber: 6,
    difficulty: 'medium',
    channel: 'email',
    sender: 'noreply@dropbox.com',
    subject: 'Alex shared a file with you',
    content:
        'Alex shared the file \'Project Draft.pdf\' with you. View it in Dropbox when convenient.',
    label: 'legit',
    hint: 'Does the tone feel routine and low-pressure?',
    explanation:
        'Legitimate — it is low-pressure, uses a trusted domain, and resembles a common collaboration workflow.',
    cues: ['routine sharing notice', 'trusted domain', 'no urgency'],
    takeawayTip:
        'Phishing often adds urgency that genuine sharing notifications do not.',
  ),
  MessageItem.contentPack(
    id: 'L7Q1',
    levelNumber: 7,
    difficulty: 'medium',
    channel: 'sms',
    sender: 'DVLA',
    subject: '',
    content:
        'Our records show you have an unpaid vehicle tax. Pay now at gov-uk-vehicle-pay.com to avoid a penalty.',
    label: 'phish',
    hint: 'Would a public body ask you to pay through an unfamiliar site?',
    explanation:
        'Phishing — it impersonates a public body and drives you to an unofficial payment domain under threat of a penalty.',
    cues: ['gov-uk-vehicle-pay.com', 'avoid a penalty', 'Pay now'],
    takeawayTip:
        'Official bodies use their own gov.uk domains, not lookalikes.',
  ),
];
