// ignore: file_names
import 'fraction.dart';
import 'yi_helpers.dart';

class YISubStep {
  final String label;
  final String latex; // ← always LaTeX now
  const YISubStep({required this.label, required this.latex});
}

class YISolverStep {
  final int number;
  final String title;
  final YIStepLayout layout;

  // Single layout fields — all LaTeX strings
  final String formulaLatex;
  final String substitutionLatex;
  final String resultLatex;
  final String explanation;
  final List<YISubStep> subSteps;

  // Dual layout fields
  final String? leftLabel;
  final String? rightLabel;
  final String? leftLatex;
  final String? rightLatex;

  const YISolverStep({
    required this.number,
    required this.title,
    this.layout = YIStepLayout.single,
    this.formulaLatex = '',
    this.substitutionLatex = '',
    required this.resultLatex,
    this.explanation = '',
    this.subSteps = const [],
    this.leftLabel,
    this.rightLabel,
    this.leftLatex,
    this.rightLatex,
  });

  const YISolverStep.single({
    required int number,
    required String title,
    required String resultLatex,
    String formulaLatex = '',
    String substitutionLatex = '',
    String explanation = '',
    List<YISubStep> subSteps = const [],
  }) : this(
          number: number,
          title: title,
          layout: YIStepLayout.single,
          formulaLatex: formulaLatex,
          substitutionLatex: substitutionLatex,
          resultLatex: resultLatex,
          explanation: explanation,
          subSteps: subSteps,
        );

  const YISolverStep.dual({
    required int number,
    required String title,
    required String leftLabel,
    required String rightLabel,
    required String leftLatex,
    required String rightLatex,
    required String resultLatex,
  }) : this(
          number: number,
          title: title,
          layout: YIStepLayout.dual,
          resultLatex: resultLatex,
          leftLabel: leftLabel,
          rightLabel: rightLabel,
          leftLatex: leftLatex,
          rightLatex: rightLatex,
        );
}

enum YIStepLayout { single, dual }

// ══════════════════════════════════════════════════════════
// SLOPE-INTERCEPT STEPS (from Standard Form)
// ══════════════════════════════════════════════════════════

List<YISolverStep> buildSlopeStepsFromStandard(
  int A,
  int B,
  int C,
  YIFraction m,
  YIFraction b,
  String sfTex,
  String gfTex,
  String eqTex,
) {
  final steps = <YISolverStep>[];
  int n = 1;
  final xTermLatex = termLatex(A, 'x', isFirst: true).trim();
  final yTermLatex = termLatex(B, 'y', isFirst: false).trim();
  final yOnlyLatex = B == 1
      ? 'y'
      : B == -1
          ? '-y'
          : '${B}y';
  final rhsTex = rhsAfterMovingXLatex(A, B, C);
  final absA = A.abs();
  final xTermLabel = absA == 1 ? 'x' : '${absA}x';

  // Step 1 — show the standard form
  steps.add(YISolverStep.single(
    number: n++,
    title: 'Standard Form',
    formulaLatex: r'Ax + By = C',
    substitutionLatex: sfTex,
    resultLatex: sfTex,
    explanation: 'Start with the given equation in standard form.',
  ));

  // Step 2 — move x-term  →  By = C − Ax
  steps.add(YISolverStep.single(
    number: n++,
    title: 'Move the x-term',
    formulaLatex: r'By = C - Ax',
    substitutionLatex: textLatex('Subtract $xTermLabel from both sides'),
    resultLatex: rhsTex,
    explanation: 'Move the x-term to the right so the y-term stays on the left.',
    subSteps: [
      YISubStep(label: 'Start with the equation', latex: sfTex),
      YISubStep(
        label: 'Subtract $xTermLabel from both sides',
        latex: '$xTermLatex $yTermLatex - ($xTermLatex) = $C - ($xTermLatex)',
      ),
      YISubStep(
        label: 'Simplify both sides',
        latex:
            '$yOnlyLatex = $C ${A > 0 ? '-' : '+'} ${A.abs() == 1 ? 'x' : '${A.abs()}x'}',
      ),
      YISubStep(label: 'Write the result', latex: rhsTex),
      const YISubStep(
        label: 'Note',
        latex: r'\text{Move the whole x-term, not just its coefficient.}',
      ),
    ],
  ));

  // Step 3 — divide everything by B  (dual card: find m, find b)
  final rawM = YIFraction(numerator: -A, denominator: B);
  final rawB = YIFraction(numerator: C, denominator: B);
  final divTex =
      'y = ${fracLatex(rawM)}x ${rawB.numerator >= 0 ? '+' : '-'} ${fracLatex(rawB.abs())}';
  final needsSimplify = divTex != eqTex;

  final subSteps = <YISubStep>[
    YISubStep(label: 'Start with the equation', latex: rhsTex),
    YISubStep(
      label: 'Divide each term by ${B}',
      latex:
          '\\frac{$yOnlyLatex}{${B}} = \\frac{${C}}{${B}} ${A > 0 ? '-' : '+'} \\frac{${A.abs()}x}{${B}}',
    ),
    YISubStep(
      label: 'Simplify the left side',
      latex:
          'y = \\frac{${C}}{${B}} ${A > 0 ? '-' : '+'} \\frac{${A.abs()}x}{${B}}',
    ),
    YISubStep(label: 'Arrange into y = mx + b', latex: divTex),
    if (needsSimplify)
      YISubStep(label: 'Simplify the fractions', latex: eqTex),
  ];

  steps.add(YISolverStep.single(
    number: n++,
    title: 'Divide both sides by ${B}',
    formulaLatex: r'y = mx + b',
    substitutionLatex: 'y = \\frac{${-A}}{${B}}x + \\frac{${C}}{${B}}',
    resultLatex: eqTex,
    explanation: 'Divide every term by the coefficient of y to isolate y.',
    subSteps: subSteps,
  ));

  // Step 4 — dual card showing m and b
  steps.add(YISolverStep.dual(
    number: n++,
    title: 'Read off slope (m) and y-intercept (b)',
    leftLabel: 'Slope  m',
    rightLabel: 'y-intercept  b',
    leftLatex: 'm = ${boxLatex(fracLatex(m))}',
    rightLatex: 'b = ${boxLatex(fracLatex(b))}',
    resultLatex: 'm = ${fracLatex(m)}, \\quad b = ${fracLatex(b)}',
  ));

  return steps;
}

// ══════════════════════════════════════════════════════════
// SLOPE-INTERCEPT STEPS (from General Form)
// ══════════════════════════════════════════════════════════

List<YISolverStep> buildSlopeStepsFromGeneral(
  int A,
  int B,
  int C,
  YIFraction m,
  YIFraction b,
  String sfTex,
  String gfTex,
  String eqTex,
) {
  final steps = <YISolverStep>[];
  int n = 1;
  final xTermLatex = termLatex(A, 'x', isFirst: true).trim();
  final yTermLatex = termLatex(B, 'y', isFirst: false).trim();
  final yOnlyLatex = B == 1
      ? 'y'
      : B == -1
          ? '-y'
          : '${B}y';
  final absA = A.abs();
  final xTermLabel = absA == 1 ? 'x' : '${absA}x';
  final generalConst = -C;

  steps.add(YISolverStep.single(
    number: n++,
    title: 'General Form',
    formulaLatex: r'Ax + By + C = 0',
    substitutionLatex: gfTex,
    resultLatex: gfTex,
    explanation: 'Start with the given equation in general form.',
  ));

  // Dynamic label for moving constant: use Add/Subtract depending on sign
  final absC = generalConst.abs();
  final constLabel = absC == 1 ? '1' : '$absC';
  final constAction = generalConst > 0 ? 'Subtract' : 'Add';
  final constOpLabel = '$constAction $constLabel from both sides';
  final standardFormNote = C == 0
      ? 'The equation is already in standard form, so keep the full x-term $xTermLabel and y-term ${yTermLatex.replaceFirst(RegExp(r'^[+-]\s*'), '')}.'
      : 'Keep the full x-term $xTermLabel while moving only the constant.';

  steps.add(YISolverStep.single(
    number: n++,
    title: C == 0 ? 'Recognize standard form' : 'Move constant to the right',
    formulaLatex: r'Ax + By = -C',
    substitutionLatex:
        C == 0 ? textLatex('No constant to move') : textLatex(constOpLabel),
    resultLatex: sfTex,
    explanation: C == 0
        ? 'Zero is already on the right, so the line is already in standard form.'
        : 'Move only the constant term so the equation becomes standard form.',
    subSteps: [
      YISubStep(label: 'Start with the equation', latex: gfTex),
      if (C != 0)
        YISubStep(
          label: constOpLabel,
          latex:
              '$xTermLatex $yTermLatex ${generalConst > 0 ? '+ $generalConst' : '- ${generalConst.abs()}'} ${generalConst > 0 ? '- $generalConst' : '+ ${generalConst.abs()}'} = 0 ${generalConst > 0 ? '- $generalConst' : '+ ${generalConst.abs()}'}',
        ),
      if (C != 0)
        YISubStep(
          label: 'Simplify both sides',
          latex: '$xTermLatex $yTermLatex = $C',
        ),
      YISubStep(
        label: C == 0 ? 'Keep the equation as is' : 'Write the standard form',
        latex: '${gfTex} \\Rightarrow ${sfTex}',
      ),
      YISubStep(
        label: 'Identify the x-term',
        latex: '$xTermLatex \\text{ is the full x-term}',
      ),
      YISubStep(
        label: 'Identify the y-term',
        latex: '$yTermLatex \\text{ is the full y-term}',
      ),
      YISubStep(label: 'Note', latex: r'\text{' + standardFormNote + '}'),
    ],
  ));

  final rawM = YIFraction(numerator: -A, denominator: B);
  final rawB = YIFraction(numerator: C, denominator: B);
  final divTex =
      'y = ${fracLatex(rawM)}x ${rawB.numerator >= 0 ? '+' : '-'} ${fracLatex(rawB.abs())}';
  final needsSimplify = divTex != eqTex;

  final subSteps = <YISubStep>[
    YISubStep(label: 'Start with the standard form', latex: sfTex),
    YISubStep(
      label: 'Subtract $xTermLabel from both sides',
      latex: '$xTermLatex $yTermLatex - ($xTermLatex) = $C - ($xTermLatex)',
    ),
    YISubStep(
      label: 'Simplify both sides',
      latex:
          '$yOnlyLatex = $C ${A > 0 ? '-' : '+'} ${A.abs() == 1 ? 'x' : '${A.abs()}x'}',
    ),
    YISubStep(
      label: 'Divide each term by ${B}',
      latex:
          '\\frac{$yOnlyLatex}{${B}} = \\frac{${C}}{${B}} ${A > 0 ? '-' : '+'} \\frac{${A.abs()}x}{${B}}',
    ),
    YISubStep(
      label: 'Simplify the left side',
      latex:
          'y = \\frac{${C}}{${B}} ${A > 0 ? '-' : '+'} \\frac{${A.abs()}x}{${B}}',
    ),
    YISubStep(label: 'Arrange into y = mx + b', latex: divTex),
    if (needsSimplify)
      YISubStep(label: 'Simplify the fractions', latex: eqTex),
  ];

  steps.add(YISolverStep.single(
    number: n++,
    title: 'Move the x-term and divide by ${B}',
    formulaLatex: r'y = mx + b',
    substitutionLatex: 'y = \\frac{${-A}}{${B}}x + \\frac{${C}}{${B}}',
    resultLatex: eqTex,
    explanation: 'From standard form, move the x-term and then divide by the coefficient of y.',
    subSteps: subSteps,
  ));

  steps.add(YISolverStep.dual(
    number: n++,
    title: 'Read off slope (m) and y-intercept (b)',
    leftLabel: 'Slope  m',
    rightLabel: 'y-intercept  b',
    leftLatex: 'm = ${boxLatex(fracLatex(m))}',
    rightLatex: 'b = ${boxLatex(fracLatex(b))}',
    resultLatex: 'm = ${fracLatex(m)}, \\quad b = ${fracLatex(b)}',
  ));

  return steps;
}

// ══════════════════════════════════════════════════════════
// SLOPE-INTERCEPT DIRECT STEPS
// ══════════════════════════════════════════════════════════

List<YISolverStep> buildSlopeInterceptDirectSteps(
  YIFraction m,
  YIFraction b,
  String eqTex,
  String sfTex,
  String gfTex,
) {
  return [
    YISolverStep.single(
      number: 1,
      title: 'Recognize slope-intercept form',
      formulaLatex: r'y = mx + b',
      substitutionLatex: eqTex,
      resultLatex: eqTex,
      explanation: 'The equation is already in the correct form.',
    ),
    YISolverStep.single(
      number: 2,
      title: 'Identify the slope (m)',
      formulaLatex: r'\text{coefficient of } x',
      substitutionLatex: '${fracLatex(m)}x',
      resultLatex: 'm = ${boxLatex(fracLatex(m))}',
      explanation: 'The slope is the number multiplied by x.',
    ),
    YISolverStep.single(
      number: 3,
      title: 'Identify the y-intercept (b)',
      formulaLatex: r'\text{the constant term}',
      substitutionLatex: fracLatex(b),
      resultLatex: 'b = ${boxLatex(fracLatex(b))}',
      explanation: 'The y-intercept is the number without a variable.',
    ),
    YISolverStep.dual(
      number: 4,
      title: 'Answer',
      leftLabel: 'Slope  m',
      rightLabel: 'y-intercept  b',
      leftLatex: 'm = ${boxLatex(fracLatex(m))}',
      rightLatex: 'b = ${boxLatex(fracLatex(b))}',
      resultLatex: 'm = ${fracLatex(m)}, \\quad b = ${fracLatex(b)}',
    ),
  ];
}

// ══════════════════════════════════════════════════════════
// STANDARD FORM STEPS
// ══════════════════════════════════════════════════════════

List<YISolverStep> buildStandardFormSteps(
  int A,
  int B,
  int C,
  String gfTex,
  String sfTex,
) {
  final xTermLatex = termLatex(A, 'x', isFirst: true).trim();
  final yTermLatex = termLatex(B, 'y', isFirst: false).trim();
  final generalConst = -C;
  final absConst = generalConst.abs();
  final constLabel = absConst == 1 ? '1' : '$absConst';
  final constAction = generalConst > 0 ? 'Subtract' : 'Add';
  final constOpLabel = '$constAction $constLabel from both sides';

  return [
    YISolverStep.single(
      number: 1,
      title: 'General Form',
      formulaLatex: r'Ax + By + C = 0',
      substitutionLatex: gfTex,
      resultLatex: gfTex,
      explanation: 'Starting equation.',
    ),
    YISolverStep.single(
      number: 2,
      title: generalConst == 0
          ? 'Recognize standard form'
          : 'Move the constant to the right',
      formulaLatex: r'Ax + By = -C',
      substitutionLatex: generalConst == 0
          ? textLatex('No constant to move')
          : textLatex(constOpLabel),
      resultLatex: sfTex,
      explanation: generalConst == 0
          ? 'The equation already has 0 on the right, so it is already in standard form.'
          : 'Move the constant term to the right side.',
      subSteps: [
        YISubStep(label: 'Start with the equation', latex: gfTex),
        if (generalConst != 0)
          YISubStep(
            label: constOpLabel,
            latex:
                '$xTermLatex $yTermLatex ${generalConst > 0 ? '+ $generalConst' : '- ${generalConst.abs()}'} ${generalConst > 0 ? '- $generalConst' : '+ ${generalConst.abs()}'} = 0 ${generalConst > 0 ? '- $generalConst' : '+ ${generalConst.abs()}'}',
          ),
        if (generalConst != 0)
          YISubStep(
            label: 'Simplify both sides',
            latex: '$xTermLatex $yTermLatex = $C',
          ),
        YISubStep(label: 'Write the standard form', latex: sfTex),
      ],
    ),
    YISolverStep.single(
      number: 3,
      title: 'Identify the coefficients',
      formulaLatex: r'Ax + By = C',
      substitutionLatex: sfTex,
      resultLatex: 'A = ${boxLatex('$A')}, \\quad B = ${boxLatex('$B')}, \\quad C = ${boxLatex('$C')}',
      explanation: 'Read the coefficients directly from standard form.',
      subSteps: [
        YISubStep(label: 'x-term', latex: '$xTermLatex \\Rightarrow A = $A'),
        YISubStep(label: 'y-term', latex: '$yTermLatex \\Rightarrow B = $B'),
        YISubStep(label: 'constant', latex: '$C \\Rightarrow C = $C'),
      ],
    ),
  ];
}

List<YISolverStep> buildGeneralFormSteps(
  int A,
  int B,
  int C,
  String sfTex,
  String gfTex,
) {
  final xTermLatex = termLatex(A, 'x', isFirst: true).trim();
  final yTermLatex = termLatex(B, 'y', isFirst: false).trim();
  final generalConst = -C;

  return [
    YISolverStep.single(
      number: 1,
      title: 'Standard Form',
      formulaLatex: r'Ax + By = C',
      substitutionLatex: sfTex,
      resultLatex: sfTex,
      explanation: 'Starting equation.',
    ),
    YISolverStep.single(
      number: 2,
      title: 'Move all terms to the left',
      formulaLatex: r'Ax + By - C = 0',
      substitutionLatex: textLatex('Subtract $C from both sides'),
      resultLatex: gfTex,
      explanation: 'Move the constant to the left so the equation equals zero.',
      subSteps: [
        YISubStep(label: 'Start with the equation', latex: sfTex),
        YISubStep(
          label: 'Subtract $C from both sides',
          latex:
              '$xTermLatex $yTermLatex - $C = $C - $C',
        ),
        YISubStep(
          label: 'Simplify both sides',
          latex:
              '$xTermLatex $yTermLatex ${generalConst >= 0 ? '+ $generalConst' : '- ${generalConst.abs()}'} = 0',
        ),
        YISubStep(label: 'Write the general form', latex: gfTex),
      ],
    ),
    YISolverStep.single(
      number: 3,
      title: 'Identify the coefficients',
      formulaLatex: r'Ax + By + C = 0',
      substitutionLatex: gfTex,
      resultLatex:
          'A = ${boxLatex('$A')}, \\quad B = ${boxLatex('$B')}, \\quad C = ${boxLatex('${-C}')}',
      explanation: 'Read the coefficients directly from general form.',
      subSteps: [
        YISubStep(label: 'x-term', latex: '$xTermLatex \\Rightarrow A = $A'),
        YISubStep(label: 'y-term', latex: '$yTermLatex \\Rightarrow B = $B'),
        YISubStep(
          label: 'constant',
          latex:
              '${generalConst >= 0 ? generalConst : '(${generalConst})'} \\Rightarrow C = $generalConst',
        ),
      ],
    ),
  ];
}

// ══════════════════════════════════════════════════════════
// STANDARD / GENERAL FROM SLOPE-INTERCEPT (STEPS)
// ══════════════════════════════════════════════════════════

List<YISolverStep> buildStandardFormFromSlopeInterceptSteps(
  YIFraction m,
  YIFraction b,
  String sfTex,
  String gfTex,
) {
  final eqTex = eqLatex(m, b);
  return [
    YISolverStep.single(
      number: 1,
      title: 'Slope-Intercept Form',
      formulaLatex: r'y = mx + b',
      substitutionLatex: eqTex,
      resultLatex: eqTex,
      explanation: 'Given equation.',
    ),
    YISolverStep.single(
      number: 2,
      title: 'Move the x-term to the left',
      formulaLatex: r'Ax + By = C',
      substitutionLatex: textLatex('Subtract the x-term from both sides'),
      resultLatex: sfTex,
      explanation:
          'Standard form: x and y on the left, constant on the right.',
    ),
  ];
}

List<YISolverStep> buildGeneralFormFromSlopeInterceptSteps(
  YIFraction m,
  YIFraction b,
  String sfTex,
  String gfTex,
) {
  final eqTex = eqLatex(m, b);
  return [
    YISolverStep.single(
      number: 1,
      title: 'Slope-Intercept Form',
      formulaLatex: r'y = mx + b',
      substitutionLatex: eqTex,
      resultLatex: eqTex,
      explanation: 'Starting equation.',
    ),
    YISolverStep.single(
      number: 2,
      title: 'Convert to Standard Form',
      formulaLatex: r'Ax + By = C',
      substitutionLatex: textLatex('Move the x-term to the left'),
      resultLatex: sfTex,
      explanation: 'Intermediate step.',
    ),
    YISolverStep.single(
      number: 3,
      title: 'Convert to General Form',
      formulaLatex: r'Ax + By + C = 0',
      substitutionLatex: textLatex('Move all terms to the left'),
      resultLatex: gfTex,
      explanation: 'General form: everything on the left equals zero.',
    ),
  ];
}

// ══════════════════════════════════════════════════════════
// X-INTERCEPT STEPS
// ══════════════════════════════════════════════════════════

List<YISolverStep> buildXInterceptSteps(
  YIFraction m,
  YIFraction b,
  YIFraction? xInt,
) {
  if (m.isZero) {
    return [
      YISolverStep.single(
        number: 1,
        title: 'Set y = 0',
        formulaLatex: r'0 = mx + b',
        substitutionLatex: '0 = (0)x + ${fracLatex(b)}',
        resultLatex: '0 = ${fracLatex(b)}',
        explanation: 'Substitute y = 0 into the equation.',
      ),
      const YISolverStep.single(
        number: 2,
        title: 'No x-intercept',
        formulaLatex: r'\text{Horizontal line}',
        substitutionLatex: r'm = 0',
        resultLatex: r'\text{No solution}',
        explanation: 'A horizontal line never crosses the x-axis.',
      ),
    ];
  }

  final negB = (b * negOneFrac).simplified();
  final rawNum = negB.numerator * m.denominator;
  final rawDen = negB.denominator * m.numerator;
  final rawXInt =
      YIFraction(numerator: rawNum, denominator: rawDen).simplified();
  final needsSimplify = xInt != null && rawXInt.toString() != xInt.toString();

  final mxPart = mxLatex(m);

  return [
    YISolverStep.single(
      number: 1,
      title: 'Set y = 0',
      formulaLatex: r'0 = mx + b',
      substitutionLatex: '0 = $mxPart + ${fracLatex(b)}',
      resultLatex: '0 = $mxPart + ${fracLatex(b)}',
      explanation:
          'Substitute y = 0. The x-intercept is where y equals zero.',
    ),
    YISolverStep.single(
      number: 2,
      title: 'Move b to the right side',
      formulaLatex: r'mx = -b',
        substitutionLatex:
            textLatex('Subtract ${fracLatex(b)} from both sides'),
      resultLatex: '$mxPart = ${fracLatex(negB)}',
      explanation: 'Isolate the x-term.',
    ),
    YISolverStep.single(
      number: 3,
      title: 'Divide both sides by m',
      formulaLatex: r'x = \frac{-b}{m}',
      substitutionLatex: 'x = \\frac{${fracLatex(negB)}}{${fracLatex(m)}}',
      resultLatex: 'x = ${boxLatex(fracLatex(xInt!))}',
      explanation: 'Dividing isolates x.',
      subSteps: needsSimplify
          ? [YISubStep(label: 'Simplify', latex: 'x = ${fracLatex(xInt)}')]
          : [],
    ),
    YISolverStep.single(
      number: 4,
      title: 'Answer — x-intercept',
      formulaLatex: r'\text{Point} = (x,\ 0)',
      substitutionLatex: 'x = ${fracLatex(xInt)}, \\quad y = 0',
      resultLatex:
          '\\text{x-intercept} = ${boxLatex('(${fracLatex(xInt)},\\ 0)')}',
      explanation: 'This is the point where the line crosses the x-axis.',
    ),
  ];
}

// ══════════════════════════════════════════════════════════
// VERTICAL LINE STEPS
// ══════════════════════════════════════════════════════════

List<YISolverStep> buildVerticalSlopeSteps(
  int A,
  int C,
  String sfTex,
  String gfTex,
) =>
    [
      YISolverStep.single(
        number: 1,
        title: 'Identify a vertical line',
        formulaLatex: r'Ax = C \quad \text{(no y-term)}',
        substitutionLatex: '${A}x = ${C}',
        resultLatex: sfTex,
        explanation: 'When there is no y-term, the line is vertical.',
      ),
      const YISolverStep.single(
        number: 2,
        title: 'Slope is undefined',
        formulaLatex: r'm = \frac{\text{rise}}{\text{run}}',
        substitutionLatex:
            r'\text{run} = 0 \Rightarrow \text{division by zero}',
        resultLatex: r'm = \text{undefined}',
        explanation: 'Vertical lines have no slope.',
      ),
    ];

List<YISolverStep> buildVerticalXSteps(
  int A,
  int C,
  YIFraction xVal,
) =>
    [
      YISolverStep.single(
        number: 1,
        title: 'Solve for x',
        formulaLatex: r'Ax = C \Rightarrow x = \frac{C}{A}',
        substitutionLatex: 'x = \\frac{${C}}{${A}}',
        resultLatex: 'x = ${boxLatex(fracLatex(xVal))}',
        explanation: 'Divide both sides by A.',
      ),
      YISolverStep.single(
        number: 2,
        title: 'State the x-intercept',
        formulaLatex: r'\text{Point} = (x,\ 0)',
        substitutionLatex: 'x = ${fracLatex(xVal)}, \\quad y = 0',
        resultLatex:
            '\\text{x-intercept} = ${boxLatex('(${fracLatex(xVal)},\\ 0)')}',
        explanation: 'All points on a vertical line share the same x-value.',
      ),
    ];
