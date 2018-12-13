module Eval

import AST;
import Resolve;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
Value sdValueOfType(boolean()) = vbool(false);
Value sdValueOfType(integer()) = vint(0);
Value sdValueOfType(string()) = vstr("");
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f)
  = ( q.name : sdValueOfType(q.questionType) | /AQuestion q := f && q has name);

// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}


// evalOnce(AForm f, Input inp, VEnv venv) 
//  = { v | AQuestion q := f && v = eval(q, inp, venv)} ; 
  
  
VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  for(/AQuestion q := f) {
    venv = eval(q, inp, venv);
  }
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  return (); 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(str x): return venv[x];
    
    // etc.
    
    default: throw "Unsupported expression <e>";
  }
}