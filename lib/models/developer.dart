class Developer {
  final String name;
  final String program;
  final String role;
  final String email;
  final String contribution;
  final String phone;
  final String groups;
  final String facebook;

  const Developer({
    required this.name,
    required this.program,
    required this.role,
    this.email = '',
    this.contribution = '',
    required this.phone,
    this.groups = '',
    this.facebook = '',
  });
}

const developers = [
  Developer(
    name: 'Joashua Marl Barimbao',
    program: 'BS Computer Science',
    role: 'Lead\nDeveloper',
    email: 'joashuabarimbao10@gmail.com',
    facebook: 'Joashua Marl Barimbao',
    contribution:
        'Wiring, Debugging, Deploying, Absolute , Strict , Non Strict, Radical , Continued , Finding the Center , Finding the Radius',
    phone: '09639201328',
    groups:
        'Mary Chris Malinao\nKym Alinsonorin\nAljhun Gallego(gwapo)\nCresa Delacruz(Documentation)\nJoseph Rebamonte\nMerjohn Pagente',
  ),
  Developer(
    name: 'Michaela Denise Ong',
    program: 'BS Computer Science',
    role: 'Developer 2 / Docs',
    facebook: 'Michaela Denise Ong',
    email: 'michaeladenis11@gmail.com',
    contribution: 'Slope, Distance , Midpoint, Documentation',
    phone: '09452238406',
    groups:
        'Marie Joy Sebusana\nSusan Rhea Tamboboy\nVenus Caliguid\nAlche Paye\nVincent Padillio\nStephen Mark Maluto',
  ),
  Developer(
    name: 'Nash Bruce Quiros',
    program: 'BS Computer Science',
    role: 'Developer 3',
    email: 'quirosnash2@gmail.com',
    facebook: 'Nash Bruce Quiros',
    contribution: 'Basic , Quadratic, Rational',
    phone: '09953941510',
    groups:
        'Cabrera Carl Edward\nTyrus Regine\nRhea Mae Bustamante\nJoshua Barientos',
  ),
  Developer(
    name: 'John Carlo Legaste',
    program: 'BS Computer Science',
    role: 'Developer 4',
    email: 'johncarlolegaste@gmail.com',
    facebook: 'John Carlo legaste',
    contribution: 'Parallel & Perpendicular(Slope), Two-Point Slope',
    phone: '09639201328',
    groups:
        'Anjelyn Campos\nAlthea Sumalpong\nHearty Abugatal\nRafol Shayne Lowelle\nNoel Sale Jr\nJeomark Jumawan\nGraceselle Managing',
  ),
  Developer(
    name: 'Clifford Probetso',
    program: 'BS Computer Science',
    role: 'Developer 5',
    email: 'clifford.probetso@gmail.com',
    contribution: 'Point Slope, Finding the Center Radius',
    facebook: 'Clifford Probetso',
    phone: '09510069125',
    groups:
        'Angelie Jerusalem\nIvan Rabanzo\nLausa Dave\nJanwell Nacario\nRoynuj Plaza ',
  ),
  Developer(
    name: 'Johnlin Redido',
    program: 'BS Computer Science',
    role: 'Developer 6',
    facebook: 'Johnlin Redido',
    email: 'linzy21x@gmail.com',
    contribution: 'Slope-Intercept_form',
    phone: '09700455407',
    groups:
        'Gretechen Tumilap\nGonzaga Blessy\nJemson Tubis\nAllysa Sharise Cagui-at\nAlyssa Jean Toso',
  ),
];
