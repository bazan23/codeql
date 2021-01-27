/**
 * @name Potentially uninitialized local variable
 * @description Using a local variable before it is initialized gives the variable a default
 *              'nil' value.
 * @kind problem
 * @problem.severity error
 * @id rb/uninitialized-local-variable
 * @tags reliability
 *       correctness
 * @precision low
 */

import ruby
import codeql_ruby.dataflow.SSA

class RelevantLocalVariableReadAccess extends LocalVariableReadAccess {
  RelevantLocalVariableReadAccess() {
    not exists(Call c |
      c.getReceiver() = this and
      c.getMethodName() = "nil?"
    )
  }
}

from RelevantLocalVariableReadAccess read, LocalVariable v
where
  v = read.getVariable() and
  exists(Ssa::Definition def |
    def.getAnUltimateDefinition() instanceof Ssa::UninitializedDefinition and
    exists(def.getARead(read))
  )
select read, "Local variable $@ may be used before it is initialized.", v, v.getName()
