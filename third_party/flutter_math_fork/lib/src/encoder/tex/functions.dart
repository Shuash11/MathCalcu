library tex_encoder_functions;
import 'package:collection/collection.dart';
import 'package:flutter_math_fork/src/ast/nodes/accent.dart';
import 'package:flutter_math_fork/src/ast/nodes/accent_under.dart';
import 'package:flutter_math_fork/src/ast/nodes/frac.dart';
import 'package:flutter_math_fork/src/ast/nodes/function.dart';
import 'package:flutter_math_fork/src/ast/nodes/left_right.dart';
import 'package:flutter_math_fork/src/ast/nodes/multiscripts.dart';
import 'package:flutter_math_fork/src/ast/nodes/nary_op.dart';
import 'package:flutter_math_fork/src/ast/nodes/over.dart';
import 'package:flutter_math_fork/src/ast/nodes/sqrt.dart';
import 'package:flutter_math_fork/src/ast/nodes/stretchy_op.dart';
import 'package:flutter_math_fork/src/ast/nodes/style.dart';
import 'package:flutter_math_fork/src/ast/nodes/symbol.dart';
import 'package:flutter_math_fork/src/ast/nodes/under.dart';
import 'package:flutter_math_fork/src/ast/options.dart';
import 'package:flutter_math_fork/src/ast/size.dart';
import 'package:flutter_math_fork/src/ast/style.dart';
import 'package:flutter_math_fork/src/ast/symbols/symbols_composite.dart';
import 'package:flutter_math_fork/src/ast/syntax_tree.dart';
import 'package:flutter_math_fork/src/ast/types.dart';
import 'package:flutter_math_fork/src/parser/tex/font.dart';
import 'package:flutter_math_fork/src/parser/tex/functions.dart';
import 'package:flutter_math_fork/src/parser/tex/functions/katex_base.dart';
import 'package:flutter_math_fork/src/parser/tex/symbols.dart';
import 'package:flutter_math_fork/src/utils/alpha_numeric.dart';
import 'package:flutter_math_fork/src/utils/unicode_literal.dart';
import 'package:flutter_math_fork/src/encoder/encoder.dart';
import 'package:flutter_math_fork/src/encoder/matcher.dart';
import 'package:flutter_math_fork/src/encoder/optimization.dart';
import 'encoder.dart';

part 'functions/accent.dart';
part 'functions/accent_under.dart';
part 'functions/frac.dart';
part 'functions/function.dart';
part 'functions/left_right.dart';
part 'functions/multiscripts.dart';
part 'functions/nary.dart';
part 'functions/sqrt.dart';
part 'functions/stretchy_op.dart';
part 'functions/style.dart';
part 'functions/symbol.dart';

const Map<Type, EncoderFun> encoderFunctions = {
  EquationRowNode: _equationRowNodeEncoderFun,
  AccentNode: _accentEncoder,
  AccentUnderNode: _accentUnderEncoder,
  FracNode: _fracEncoder,
  FunctionNode: _functionEncoder,
  LeftRightNode: _leftRightEncoder,
  MultiscriptsNode: _multisciprtsEncoder,
  NaryOperatorNode: _naryEncoder,
  SqrtNode: _sqrtEncoder,
  StretchyOpNode: _stretchyOpEncoder,
  SymbolNode: _symbolEncoder,
  StyleNode: _styleEncoder,
};

EncodeResult _equationRowNodeEncoderFun(GreenNode node) =>
    EquationRowTexEncodeResult((node as EquationRowNode)
        .children
        .map(encodeTex)
        .toList(growable: false));

final optimizationEntries = [
  ..._fracOptimizationEntries,
  ..._functionOptimizationEntries,
]..sortBy<num>((entry) => -entry.priority);
