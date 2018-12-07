module Check

import AST;
import Resolve;
import Message; // see standard library
import Set;

// The different types we check for
data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];

// Pattern matching the types and mapping them to our data Type
Type aType2Type(boolean()) = tbool();
Type aType2Type(integer()) = tint();
Type aType2Type(string()) = tstr();
default Type aType2Type(AType _) = tunknown();

// Collect all questions of the form into a relational set
TEnv collect(AForm f) = 
 { <q.src, q.name, q.query, aType2Type(q.questionType)> | /AQuestion q := f && q has name};

// Combine the resulting messages of checking all questions
set[Message] check(AForm f, TEnv tenv, UseDef useDef)
  = ( {} | it + check(q, tenv, useDef) | /AQuestion q := f );

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) 
  = {warning("Duplicate label", q.src) | size(tenv[q.label]) > 1} +
   {error("Same question names with different types",q.src) | q has name && size((tenv<1,3>)[q.name]) > 1 }; 


// Check an expression for invalid semantics
// This is functional style
set[Message] check(ref(str name, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Undeclared question", u) | useDef[u] == {} };
set[Message] check(multiply(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match int", u) | !BinaryAExprMatchType(ex1, ex2, tint(), tenv, useDef) };
set[Message] check(divide(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match int", u) | !BinaryAExprMatchType(ex1, ex2, tint(), tenv, useDef) };
set[Message] check(addition(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match int", u) | !BinaryAExprMatchType(ex1, ex2, tint(), tenv, useDef) };
set[Message] check(subtraction(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match int", u) | !BinaryAExprMatchType(ex1, ex2, tint(), tenv, useDef) };
set[Message] check(greaterThan(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match int", u) | !BinaryAExprMatchType(ex1, ex2, tint(), tenv, useDef) };
set[Message] check(lessThan(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match int", u) | !BinaryAExprMatchType(ex1, ex2, tint(), tenv, useDef) };
set[Message] check(lessThanEq(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match int", u) | !BinaryAExprMatchType(ex1, ex2, tint(), tenv, useDef) };
set[Message] check(greaterThanEq(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match int", u) | !BinaryAExprMatchType(ex1, ex2, tint(), tenv, useDef) };
set[Message] check(equals(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match", u) | typeOf(ex1, tenv, useDef) != typeOf(ex2, tenv, useDef) };
set[Message] check(notEquals(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match", u) | typeOf(ex1, tenv, useDef) != typeOf(ex2, tenv, useDef) };
set[Message] check(and(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match", u) | typeOf(ex1, tenv, useDef) != typeOf(ex2, tenv, useDef) };
set[Message] check(or(AExpr ex1, AExpr ex2, src = loc u), TEnv tenv, UseDef useDef)
 = { error("Types dont match", u) | typeOf(ex1, tenv, useDef) != typeOf(ex2, tenv, useDef) };

// Helper to check if expression types match
bool BinaryAExprMatchType(AExpr ex1, AExpr ex2, Type t, TEnv tenv, UseDef useDef)
 = typeOf(ex1, tenv, useDef) == typeOf(ex2, tenv ,useDef) && typeOf(ex1, tenv, useDef) == t;

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(str x, src = loc u), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
Type typeOf(ref(str x, src = loc u), TEnv tenv, UseDef useDef) = t
 when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv;
Type typeOf(string(str string)) = tstr();
Type typeOf(boolean(bool b)) = tbool();
Type typeof(integer(int i), TEnv tenv, UseDef useDef) = tint();
Type typeof(parentheses(AExpr ex), TEnv tenv, UseDef useDef) = typeOf(ex, tenv, useDef);
Type typeof(negation(AExpr ex), TEnv tenv, UseDef useDef) = typeOf(ex, tenv, useDef);
Type typeof(multiply(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tint();
Type typeof(divide(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tint();
Type typeof(addition(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tint();
Type typeof(subtraction(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tint();
Type typeof(greaterThan(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tbool(); 
Type typeof(lessThan(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tbool();
Type typeof(lessThanEq(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tbool();
Type typeof(greaterThanEq(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tbool();
Type typeof(equals(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tbool();
Type typeof(notEquals(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tbool();
Type typeof(and(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tbool();
Type typeof(or(AExpr ex1, AExpr ex2), TEnv tenv, UseDef useDef) = tbool();
default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 

// Old way of doing things imperatively:
/*set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(str name, src = loc u):
      msgs += { error("Undeclared question", u) | useDef[u] == {} };
    case multiply(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match int", u) | !BinaryAExprMatchType(e, tint(), tenv, useDef) };
    case divide(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match int", u) | !BinaryAExprMatchType(e, tint(), tenv, useDef) };
    case addition(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match int", u) | !BinaryAExprMatchType(e, tint(), tenv, useDef) };
    case subtraction(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match int", u) | !BinaryAExprMatchType(e, tint(), tenv, useDef) };
    case greaterThan(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match int", u) | !BinaryAExprMatchType(e, tint(), tenv, useDef) };
    case lessThan(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match int", u) | !BinaryAExprMatchType(e, tint(), tenv, useDef) };
    case lessThanEq(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match int", u) | !BinaryAExprMatchType(e, tint(), tenv, useDef) };
    case greaterThanEq(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match int", u) | !BinaryAExprMatchType(e, tint(), tenv, useDef) };
    case equals(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match", u) | typeOf(e.ex1, tenv, useDef) != typeOf(e.ex2, tenv, useDef) };
    case notEquals(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match", u) | typeOf(e.ex1, tenv, useDef) != typeOf(e.ex2, tenv, useDef) };
    case and(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match", u) | typeOf(e.ex1, tenv, useDef) != typeOf(e.ex2, tenv, useDef) };
    case or(AExpr ex1, AExpr ex2, src = loc u):
      msgs += { error("Types dont match", u) | typeOf(e.ex1, tenv, useDef) != typeOf(e.ex2, tenv, useDef) };

  }
  
  return msgs; 
}*/

