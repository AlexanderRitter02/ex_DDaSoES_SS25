from collections.abc import Iterable
from enum import Enum, auto, unique
from typing import NamedTuple

import networkx as nx


class OpType(Enum):
    """Supported operations types for the DSES synthesis flow"""

    Constant = auto()
    And = auto()
    Xor = auto()
    Or = auto()
    Nor = auto()
    Invert = auto()
    Nand = auto()
    Add = auto()
    Sub = auto()
    Mult = auto()
    LShift = auto()
    RShift = auto()
    Eq = auto()
    NotEq = auto()
    Lt = auto()
    LtE = auto()
    Gt = auto()
    GtE = auto()

    def __str__(self):
        return self.name


# Node Attribute
class Attr(NamedTuple):
    """Attributes for a operation node of the DSES synthesis flow"""

    op_type: OpType
    exec_time: int
    area: float
    scheduled_time: int


class DSESGraph:
    """Wrapper around a networkx graph, tuned for VLSI algorithms"""

    def __init__(self):
        # Control Flow Graph
        self._GRAPH = nx.DiGraph()
        self._GRAPH.graph["splines"] = "false"
        # Node Attribute Map: dict[int, attribute]
        self._node_attributes = dict()

    @property
    def GRAPH(self):
        return self._GRAPH

    @property
    def node_attributes(self):
        return self._node_attributes

    # Helper functions returns id of new node or 0 if no nodes exist
    def get_new_node_id(self):
        if len(self._node_attributes):
            return max(self._node_attributes.keys()) + 1
        else:
            return 0

    def get_total_area(self):
        return sum([n.area for n in self._node_attributes.values()])

    # gets new node id, creates node and adds it to Graph
    def add_node(self, op_type: OpType, exec_time: int = 1, area: float = 0.0, children=None):
        node_id = self.get_new_node_id()
        self._node_attributes[node_id] = Attr(op_type, exec_time, area, -1)
        self._GRAPH.add_node(node_id)
        self._GRAPH.nodes[node_id]["label"] = str(self._node_attributes[node_id].op_type)
        if children is not None:
            if isinstance(children, Iterable):
                for v in children:
                    self.add_edge(node_id, v)
            else:
                self.add_edge(node_id, children)
        return node_id

    # adds edge from node u to node v
    def add_edge(self, u: int, v: int):
        if not (self._node_attributes.get(u, False) and self._node_attributes.get(v, False)):
            RuntimeWarning(f'Node "{u}" or Node "{v}" does not exist')
        self._GRAPH.add_edge(u, v)
        self._GRAPH[u][v]["parent_type"] = self._GRAPH.nodes[u]["label"]
        self._GRAPH[u][v]["child_type"] = self._GRAPH.nodes[v]["label"]

    def reset_graph(self):
        for n in self._GRAPH.nodes:
            self._GRAPH.nodes[n]["fillcolor"] = "white"
            self._GRAPH.nodes[n]["label"] = str(self._node_attributes[n].op_type)
            if n not in self._node_attributes:
                self._GRAPH.delte_node(n)
        for n, v in self._node_attributes.items():
            self._node_attributes[n] = self._node_attributes[n]._replace(scheduled_time=-1)
        for e in self._GRAPH.edges:
            self._GRAPH.edges[e]["label"] = ""

    # transforms the graph to dot Graph and creates pdf of graph
    def graph_to_dot(self, fn="graph"):
        import pathlib
        from subprocess import check_call

        fp = pathlib.Path(__file__).parent.absolute() / f"{fn}.dot"
        nx.drawing.nx_agraph.write_dot(self._GRAPH, fp)
        check_call(["dot", "-Tpdf", fp, "-o", f"{fn}.pdf"])
        if fp.exists():
            fp.unlink()

    # transforms the graph to dot Graph and creates pdf of graph
    def schedule_to_dot(self, fn):
        import graphviz as gv

        levels = dict()
        for n, v in self._node_attributes.items():
            levels[v.scheduled_time] = [n] + levels.get(v.scheduled_time, list())

        hidden = list()
        for i in range(max(levels.keys())):
            if i not in levels:
                # Create hidden node
                node_id = f"hidden{i}"
                levels[i] = [node_id]
                hidden += [i]

        # Define Graph
        dot = gv.Digraph("schedule")
        dot.attr(splines="false")
        dot.attr(outputorder="edgesfirst")

        # Define Subgraphs
        for i, ns in sorted(levels.items(), key=lambda x: x[0]):
            sg = gv.Digraph(f"level{i}")
            sg.attr(rank="same")
            # Define number node
            numbernode = f"numbernode{i}"
            sg.node(numbernode, label=str(i), shape="plaintext", group="left")
            sg.edge(numbernode, str(ns[0]), style="invis")
            # Define anker node
            ankernode = f"ankernode{i}"
            sg.node(ankernode, style="invis", group="right")
            sg.edge(str(ns[-1]), ankernode, style="invis")
            for n in ns:
                if i in hidden:
                    sg.node(
                        str(n),
                        style="invis",
                    )
                else:
                    sg.node(
                        str(n),
                        label=str(self._node_attributes[n].op_type) + ":" + str(n),
                        style="filled",
                        fillcolor=self._GRAPH.nodes[n]["fillcolor"],
                    )
            # Force Ordering
            for u, v in zip(ns[:-1], [ns[(j + 1) % len(ns)] for j, x in enumerate(ns)][:-1]):
                sg.edge(str(u), str(v), style="invis")

            dot.subgraph(sg)

        # Define Edges
        for u, v in self._GRAPH.edges:
            e = self._GRAPH.get_edge_data(u, v, None)
            if e:
                dot.edge(str(u), str(v), label=e["label"])

        # Define Hidden Edges
        for i in range(max(levels.keys()) + 1):
            if levels.get(i + 1, None) is not None:
                dot.edge(
                    str(levels[i][0]),
                    str(levels[i + 1][0]),
                    ltail=f"level{i + 1}",
                    style="invis",
                )
                dot.edge(f"numbernode{i}", f"numbernode{i + 1}", style="invis")
                dot.edge(f"ankernode{i}", f"ankernode{i + 1}", style="invis")
            dot.edge(f"numbernode{i}", f"ankernode{i}", style="dotted", dir="none")

        import pathlib

        dot_file = pathlib.Path(fn).absolute()
        dot.render(pathlib.Path(__file__).parent.absolute() / dot_file, format="pdf")
        if dot_file.exists():
            dot_file.unlink()

    # applies asap Algorithm on the Graph
    def asap(self):
        self.reset_graph()
        for n in nx.topological_sort(self._GRAPH):
            if len(list(self._GRAPH.predecessors(n))):
                self._node_attributes[n] = self._node_attributes[n]._replace(
                    scheduled_time=(
                        # finds slowest predecessor node and calculate schedule time of current node
                        # by adding exec_time and schedule_time
                        self._node_attributes[
                            max(
                                self._GRAPH.predecessors(n),
                                key=lambda x: self._node_attributes[x].scheduled_time
                                + self._node_attributes[x].exec_time,
                            )
                        ].scheduled_time
                        + self._node_attributes[
                            max(
                                self._GRAPH.predecessors(n),
                                key=lambda x: self._node_attributes[x].scheduled_time
                                + self._node_attributes[x].exec_time,
                            )
                        ].exec_time
                    )
                )
            else:
                # if no predecessors default to scheduling at time 0
                self._node_attributes[n] = self._node_attributes[n]._replace(scheduled_time=0)

    # applies alap Algorithm on the Graph
    def alap(self, goal: int):
        self.reset_graph()
        for n in reversed(list(nx.topological_sort(self._GRAPH))):
            if len(list(self._GRAPH.successors(n))):
                self._node_attributes[n] = self._node_attributes[n]._replace(
                    # finds fastest succsessor node and calculate schedule time of current node
                    # by subtracting schedule time of succsessor with exec_time of current node
                    scheduled_time=(
                        self._node_attributes[
                            min(
                                self._GRAPH.successors(n),
                                key=lambda x: self._node_attributes[x].scheduled_time,
                            )
                        ].scheduled_time
                        - self._node_attributes[n].exec_time
                    )
                )
            else:
                # if no predecessors default to schedule node at goal-1
                self._node_attributes[n] = self._node_attributes[n]._replace(
                    scheduled_time=goal - 1
                )
        for n, v in self._node_attributes.items():
            # if schedule is not possible
            if v.scheduled_time < 0:
                raise RuntimeError(f'Cannot schedule with ALAP goal "{goal}"')

    # Assign each node to a ressource
    def ressource_binding(self, hls_lib):
        # For simplicity reasons, our setup does not allow that multiple function units can execute the same operation type
        for i, c0 in hls_lib:
            for j, c1 in hls_lib:
                if (i != j) and any([(o in c1) for o in c0]):
                    raise RuntimeError(
                        "HLS Lib operations can only be execution by single computational unit"
                    )

        # Check that each nodes can be assigned to a function unit
        for n, t in self._node_attributes.items():
            if not any([t.op_type in c for _, c in hls_lib]):
                raise RuntimeError(f'HLS Lib does not contain op type "{t.op_type}"')

        # Each function unit gets its own color
        def random_color():
            import random

            def rand():
                return random.randint(100, 255)

            return "#%02X%02X%02X" % (rand(), rand(), rand())

        # Undirected Graph
        comp_graph = nx.Graph()

        # Add all nodes
        for n in self._node_attributes.keys():
            comp_graph.add_node(n)
            comp_graph.nodes[n]["label"] = str(self._node_attributes[n].op_type) + ":" + str(n)

        # TODO START
        # 1. Add edges

        # Without conflict (v_i, v_j):
        # - same type (of functional unit)
        # - scheduled NOT in parallel OR mutually exclusive (only one may be used at a time)

        # Compatibility Graph: comp_graph
        # Only contains nodes currently

        # Idea: Check all pairs (v_i, v_j) of node attributes and create edge if compatible (n^2)
        print("Adding edges")
        from itertools import combinations
        for vi, vj in combinations(self.node_attributes.keys(), 2):
            type_vi = self._node_attributes[vi].op_type
            type_vj = self._node_attributes[vj].op_type

            # 1. Don't add edge if not the same type
            if type_vi != type_vj:
                continue

            # 2. Scheduled in parallel
            # fixed: Execution time is also taken into account
            start_time_i = self.node_attributes[vi].scheduled_time
            start_time_j = self.node_attributes[vj].scheduled_time
            end_time_i   = start_time_i + self.node_attributes[vi].exec_time
            end_time_j   = start_time_j + self.node_attributes[vj].exec_time

            do_ranges_overlap = min(start_time_i, start_time_j) <= min(end_time_i, end_time_j)
            do_ranges_overlap = not (end_time_i <= start_time_j or end_time_j <= start_time_i)
            mutually_exclusive = False # TODO: Implement that

            if not do_ranges_overlap or mutually_exclusive:
                # If ranges overlap, then they are scheduled in parallel and should be discarded
                # TODO: Check if necessary since scheduling should have already prevented that, right?
                comp_graph.add_edge(vi, vj)


        # 2. Make cliques

        # Algorithm to find minimum number of cliques that cover the whole graph
        # -> try to get maximum cliques always
        nodes_to_process = set(self._node_attributes.keys())
        unique_cliques = (
            list()
        )  # Type must be list[list[int]], where the inner list contains the nodes within one clique
        unique_cliques = []

        while nodes_to_process:

            remaining_graph = comp_graph.subgraph(nodes_to_process)
            max_cliques = nx.find_cliques(remaining_graph)

            # Use and remove largest clique
            largest_clique = max(max_cliques, key=len)
            unique_cliques.append(largest_clique)
            nodes_to_process -= set(largest_clique)
        # TODO END

        # Get the clique coverage numbeor
        k = max(unique_cliques, key=lambda x: len(x))
        print(f"Amount of cliques: {k}")

        # Color each opertion with the color of the clique it gets assigned to.
        for l in unique_cliques:
            rc = random_color()
            for n in l:
                self._GRAPH.nodes[n]["fillcolor"] = rc
                comp_graph.nodes[n]["fillcolor"] = rc
                comp_graph.nodes[n]["style"] = "filled"

        # Annotate function unit types and return
        return [
            (
                [i for i, comp_unit in hls_lib if self._node_attributes[c[0]].op_type in comp_unit][
                    0
                ],
                c,
            )
            for c in unique_cliques
        ], k

    # resource binding end

    # This function perform a register allocation using the left edge algorithm on the graphs' edges
    def register_allocation(self):
        # TODO START
        # 1. Create intervals based on edges

        # To do this, you must create a list of tuples with start and end times from the edges of the schedule.
        intervals = []
        for i, (vi, vj) in enumerate(self._GRAPH.edges):
            start = self.node_attributes[vi].scheduled_time
            end = self.node_attributes[vj].scheduled_time
            intervals.append((i, start, end))
    

        # 2. LEA algorithm ``push all intervals to the left``

        # Ordering primarly by start time, secondary then by lifetime
        print(intervals)
        intervals.sort(key=lambda interval: (interval[1], -(interval[2] - interval[1])))
        print(intervals)


        # This the intervals similar to the LEA algorithm in the lecture
        LEA_bins = [[intervals[0]]]

        # Sort the intervals into bins, if they do not overlap with an interval that is already in the bin
        for i, b, e in intervals[1:]:
            print(f"Current bins: {LEA_bins}")
            added = False
            for k, l in enumerate(LEA_bins):
                # Check if the intervals overlap, if so move to new bin

                end_interval = l[-1]

                # b = start_time (wtf is up with the naming here)
                if b >= end_interval[2]: # start_time(of interval to be added into bin) >= end_time(last interval in bin)
                    print(f"adding {(i,b,e)}")
                    l.append((i,b,e))
                    added = True
                    break
            

            # Create new bin as no bin was found
            print("Creating new bin")
            if not added:
                LEA_bins += [[(i, b, e)]]

        # TODO END

        # Assign labels to each edge that show the associated bin, i.e., which register they get assigned to.
        for i, e in enumerate(self._GRAPH.edges):
            self._GRAPH.edges[e]["label"] = (
                "edge: "
                + str(i)
                + ", reg: "
                + str([j for j, l in enumerate(LEA_bins) for (k, _, _) in l if i == k][0])
            )

        return {i: [j for (j, _, _) in l] for i, l in enumerate(LEA_bins)}
    

def task1_graph1():

    HLS_LIB = list(
        enumerate(
            [
                [  # FU 0
                    OpType.Mult,
                    OpType.Invert
                ],
                [  # FU 1
                    OpType.Add,
                    OpType.And
                ],
                [
                    OpType.Constant
                ]
            ]
        )
    )
    
     # Graph example from lecture
    G = DSESGraph()
    invert1 = G.add_node(OpType.Invert)
    invert2 = G.add_node(OpType.Invert)
    invert3 = G.add_node(OpType.Invert)
    invert4 = G.add_node(OpType.Invert)
    mult1 = G.add_node(OpType.Mult)
    mult2 = G.add_node(OpType.Mult)
    add1 = G.add_node(OpType.Add)
    add2 = G.add_node(OpType.Add)
    add3 = G.add_node(OpType.Add)
    constant = G.add_node(OpType.Constant)
    constant2 = G.add_node(OpType.Constant)
    and_n = G.add_node(OpType.And)

    G.add_edge(constant2, add1)
    G.add_edge(constant2, add1)
    G.add_edge(add1, invert2)

    G.add_edge(invert1, invert2)
    G.add_edge(invert2, mult1)
    G.add_edge(invert3, mult1)
    G.add_edge(invert3, add2)
    G.add_edge(constant, add2)
    G.add_edge(add2, and_n)
    G.add_edge(mult2, and_n)
    G.add_edge(constant, mult2)
    G.add_edge(constant, mult2)
    G.add_edge(mult1, add3)
    G.add_edge(and_n, add3)
    G.add_edge(mult2, invert4)
    G.graph_to_dot("graph_test1")

    #G.asap(); G.schedule_to_dot("g2_asap")
    #G.asap()
    G.alap(goal=7)
    G.schedule_to_dot("alap_test1")


    if True:  # Enable me when implemented
        # Ressource binding
        rb, k = G.ressource_binding(HLS_LIB)
        print(f"Ressource Binding (k = {k}), requires {len(rb)} units, with node mapping:")
        for i, l in rb:
            print(f"Function unit instance {i} computes nodes: {l}")
        print()

    G.schedule_to_dot("binded_graph_test1")

    if True:  # Enable me when implemented
        # Register Allocation
        ra = G.register_allocation()
        print(f"Register Binding, requires {len(ra)} register, with edge mapping:")
        for i, l in ra.items():
            print(f"Register {i} stores values of edges: {l}")
        print()

    # Print schedule, with coloring and edgle labeling (when implemented)
    G.schedule_to_dot("binded_and_allocated_graph_test1")



def task1_graph2():

    HLS_LIB = list(
        enumerate(
            [
                [  # FU 0
                    OpType.Mult,
                    OpType.Invert
                ],
                [  # FU 1
                    OpType.Add,
                    OpType.And
                ],
                [
                    OpType.Constant
                ]
            ]
        )
    )

    # For binding,the same 1 inverter can be used for the chain
    
    # This inverter chain should use the same register
    # The non-overlapping lifetimes (of the multipliers) are used in the same,
    # while the overlapping two (adders) not
    G = DSESGraph()


    
    mul = G.add_node(OpType.Mult)
    add = G.add_node(OpType.Add)
    add2 = G.add_node(OpType.Add, children=add)
    
    

    invert5 = G.add_node(OpType.Invert, children=[mul, add])
    invert4 = G.add_node(OpType.Invert, children=[invert5, mul])
    mult_inbetween = G.add_node(OpType.Invert, children=[invert4, add])
    mult1 = G.add_node(OpType.Mult, children=mult_inbetween)
    invert2 = G.add_node(OpType.Invert, children=mult_inbetween)
    invert1 = G.add_node(OpType.Invert, children=invert2)
    G.graph_to_dot("graph_test2")

    #G.asap(); G.schedule_to_dot("g2_asap")
    G.asap()
    G.schedule_to_dot("asap_test2")


    if True:  # Enable me when implemented
        # Ressource binding
        rb, k = G.ressource_binding(HLS_LIB)
        print(f"Ressource Binding (k = {k}), requires {len(rb)} units, with node mapping:")
        for i, l in rb:
            print(f"Function unit instance {i} computes nodes: {l}")
        print()

    G.schedule_to_dot("binded_graph_test2")

    if True:  # Enable me when implemented
        # Register Allocation
        ra = G.register_allocation()
        print(f"Register Binding, requires {len(ra)} register, with edge mapping:")
        for i, l in ra.items():
            print(f"Register {i} stores values of edges: {l}")
        print()

    # Print schedule, with coloring and edgle labeling (when implemented)
    G.schedule_to_dot("binded_and_allocated_graph_test2")


if __name__ == "__main__":
    # HLS Lib example from lecture
    HLS_LIB = list(
        enumerate(
            [
                [  # FU 0
                    OpType.Mult,
                ],
                [  # FU 1
                    OpType.Add,
                    OpType.Gt,
                    OpType.Sub,
                ],
            ]
        )
    )

    # Graph example from lecture
    G = DSESGraph()
    n0 = G.add_node(OpType.Sub)
    n1 = G.add_node(OpType.Sub, children=n0)
    n2 = G.add_node(OpType.Gt)
    n3 = G.add_node(OpType.Add)
    n4 = G.add_node(OpType.Mult, children=n0)
    n5 = G.add_node(OpType.Mult, children=n1)
    n6 = G.add_node(OpType.Add, children=n2)
    n7 = G.add_node(OpType.Mult, children=n3)
    n8 = G.add_node(OpType.Mult, children=n4)
    n9 = G.add_node(OpType.Mult, children=n5)
    n10 = G.add_node(OpType.Mult, children=n5)
    G.graph_to_dot("base_graph")

    # Schedule (use either)
    G.asap()
    G.schedule_to_dot("scheduled_graph")

    if True:  # Enable me when implemented
        # Ressource binding
        rb, k = G.ressource_binding(HLS_LIB)
        print(f"Ressource Binding (k = {k}), requires {len(rb)} units, with node mapping:")
        for i, l in rb:
            print(f"Function unit instance {i} computes nodes: {l}")
        print()

    G.schedule_to_dot("binded_graph")

    if True:  # Enable me when implemented
        # Register Allocation
        ra = G.register_allocation()
        print(f"Register Binding, requires {len(ra)} register, with edge mapping:")
        for i, l in ra.items():
            print(f"Register {i} stores values of edges: {l}")
        print()

    # Print schedule, with coloring and edgle labeling (when implemented)
    G.schedule_to_dot("binded_and_allocated_graph")

    task1_graph1()
    task1_graph2()
