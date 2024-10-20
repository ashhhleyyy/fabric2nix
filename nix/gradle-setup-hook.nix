{ makeSetupHook, gradle-unwrapped }:

makeSetupHook {
  name = "gradle-setup-hook";
  propagatedBuildInputs = [ gradle-unwrapped ];
  passthru.gradle = gradle-unwrapped;
} ./setup-hook.sh
