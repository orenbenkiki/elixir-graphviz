elixir-graphviz
===============

Generate GraphViz diagrams from Elixir code.

## Restrictions

This module has the following restrictions:

* Everything has to be properly declared: GraphViz provides a lot of
  mechanisms for setting up and using default values, but this module doesn't
  provide access to any of them. This is hopefully less of an issue for a
  code-generated diagram.

* Little control over order: `dot `is notoriously preverse when it comes to
  ordering nodes or clusters of the same rank. One way to (try to) force this
  order is to tightly control the order they appear in the file, but this
  module isn't very friendly in this regard. It basically emits elements in
  the reverse of the order in which they were added. Arguably `dot` should
  finally provide a better way to control this issue, but there seems little
  chance of that ever hapenning.

* No validation: GraphViz provides a large but finite set of attributes and
  values, but this module just allows you to emit anything you want without
  any regard to whether GraphViz will accept them or not.

* No formatting: Attributes are expected to be printable (that is, allowed
  inside `\#{...}`. There is no automatic `"` added around attribute values
  so it is the caller's responsibility to do any form of quoting needed
  (e.g., if a label contains spaces, the caller needs to use `inspect("Foo
  Bar")` as the label instead of simply `"Foo Bar"`. Likewise, if a style
  should be `"round,filled"` then the caller needs to use
  `inspect("round,filled")` instead of, say, a nice `[ :round, :filled ]`.
  The only upside to this is that setting a label to a simple `<...html...>`
  "just works". That, and the fact that all attributes are printed exactly
  the same without any complex special confusing rules. Again, this is
  hopefully less of an issue for a code-generated diagram.

* Addition only: You can add elements to the graph but you can't take them
  out. Mercifully it is at least possible to update elements after they have
  been added.

* The node and edge records are defined in a way that caters to directed
  graphs. Edges therefore have `source` and `target` nodes, and nodes have
  separate `incoming` and `outgoing` edge lists.

* The output isn't formatted in the prettiest or the most compact possible
  way. On the bright side it is very regular, so you can get away with a
  simplified parser if you want to post-process it.

Otherwise this is a fairly complete way to generate GraphViz diagrams.

## How to use this

First, create a new graph:

    graph = GraphViz.Graph[ name: "name", is_strict: true, is_directed: true, attributes: [ label: "A label", rankdir: :LR ] ]

Then, add stuff into the graph:

    graph = graph
         |> GraphViz.add(GraphViz.SubGraph[ id: id_of_cluster, is_cluster: true, attributes: [ label: "Cluster" ] ])
         |> GraphViz.add(GraphViz.Node[ id: id_of_source, parent: id_of_cluster, attributes: [ label: "Source" ] ])
         |> GraphViz.add(GraphViz.Node[ id: id_of_target, attributes: [ label: "Target" ] ])
         |> GraphViz.add(GraphViz.Edge[ id: id_of_edge, source: id_of_source, target: id_of_target, attributes: [ label: "Edge" ] ])

You will need to use some sort of a unique identifier for each element
(including edges!). Using references (`make_ref`) is OK, as is using anything
else which is unique.

You can lookup existing elements by their identifier:

    element = GraphViz.lookup(graph, identifier)

You can give any attribute you want, with any value you want. GraphViz will
silently ignore unknown attributes. As long as you keep the identifiers
unmolested, you can update an element after creating it:

    graph = GraphViz.update(graph, new_version_of_some_element)

Finally, you can print the graph:

    GraphViz.print(:stdio, graph)

