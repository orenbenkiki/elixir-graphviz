
# This Makefile assumes you have elixir etc. in your path. The following
# variable is only used for the dialyzer.
ELIXIR_PATH=../elixir

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

clean:
	rm -rf ebin cover

.dialyzer_plt:
	@ echo "==> Adding Erlang/OTP basic applications to PLT"
	@ dialyzer --output_plt .dialyzer_plt --build_plt --apps erts kernel stdlib compiler syntax_tools inets crypto ssl
	@ echo "==> Adding Elixir to PLT..."
	@ dialyzer --plt .dialyzer_plt --add_to_plt -r $(ELIXIR_PATH)/lib/*/ebin

dialyze: .dialyzer_plt compile
	@ echo "==> Dialyzing GraphViz..."
	@ dialyzer --plt .dialyzer_plt -r ebin
