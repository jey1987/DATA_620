import networkx as nx
G = nx.Graph()
G.add_node("Charlotte")
G.add_node("Winston Salem")
G.add_node("Virginia")
G.add_node("Washington")
G.add_node("Baltimore")
G.add_node("New Jersey")
G.add_node("New York")
G.add_node("Boston")
G.add_node("Vermont")
G.add_node("Connecticut")

G.add_edge("Charlotte","Winston Salem")
G.add_edge("Winston Salem","Virginia")
G.add_edge("Virginia","Washington")
G.add_edge("Washington","Charlotte")
G.add_edge("Baltimore","New Jersey")
G.add_edge("Virginia","New York")
G.add_edge("New York","Washington")
G.add_edge("New Jersey","New York")
G.add_edge("Charlotte","New Jersey")
G.add_edge("New Jersey","Winston Salem")
G.add_edge("Charlotte","Baltimore")
G.add_edge("Baltimore","Winston Salem")
G.add_edge("Virginia","New Jersey")
G.add_edge("New Jersey","Washington")
G.add_edge("Winston Salem","Boston")
G.add_edge("Virginia","Boston")
G.add_edge("Boston","Vermont")
G.add_edge("Vermont","Connecticut")


nx.draw(G, with_labels=True,font_weight='bold')
