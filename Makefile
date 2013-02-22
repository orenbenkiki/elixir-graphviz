# This assumes you have elixir etc. in your path.

.PHONY: test

all: README.md compile

README.md: lib/graphviz.ex Makefile
	awk '\
        BEGIN { print "elixir-graphviz\n===============\n"; to_print = 0 } \
        to_print >= 0 && /Generate/ { to_print = 1 } \
        /  """/ { to_print = -1 } \
        to_print > 0 { sub(/  /, ""); print; } \
        ' < lib/graphviz.ex > README.md

compile:
	mix compile

test:
	mix test

coverage:
	mix test --coverage

.dialyzer.base_plt:
	@ echo "==> Adding Erlang/OTP basic applications to a new base PLT"
	@ dialyzer --output_plt .dialyzer.base_plt --build_plt --apps erts kernel stdlib compiler syntax_tools inets crypto ssl

dialyze: .dialyzer.base_plt
	@ rm -f .dialyzer_plt
	@ cp .dialyzer.base_plt .dialyzer_plt
	@ echo "==> Adding Elixir to PLT..."
	@ dialyzer --plt .dialyzer_plt --add_to_plt -r lib/elixir/ebin lib/ex_unit/ebin lib/mix/ebin lib/iex/ebin lib/eex/ebin lib/graphviz/ebin
	@ echo "==> Dialyzing Elixir..."
	@ dialyzer --plt .dialyzer_plt -r lib/elixir/ebin lib/ex_unit/ebin lib/mix/ebin lib/iex/ebin lib/eex/ebin lib/graphviz/ebin
