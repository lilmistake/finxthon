import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:notes/database_service.dart';
import 'package:notes/models/models.dart';
import '../home_product_details.dart';

class TrackProductButton extends StatelessWidget {
  const TrackProductButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => {
          showDialog(
              context: context,
              builder: (context) {
                return _TrackProductDialog();
              })
        },
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.link),
              SizedBox(
                width: 10,
              ),
              Text("Track Product")
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackProductDialog extends StatelessWidget {
  _TrackProductDialog();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        surfaceTintColor: Theme.of(context).colorScheme.background,
        child: Container(
          height: 170,
          width: 600,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _controller,
                  validator: (value) {
                    // regex for IPFS CID
                    RegExp ipfsCIDRegExp = RegExp(
                        r'^(Qm[1-9A-HJ-NP-Za-km-z]{44}|b[a-km-zA-HJ-NP-Z2-9]{1}[1-9A-HJ-NP-Za-km-z]*)$');

                    if (value == null ||
                        value.isEmpty ||
                        ipfsCIDRegExp.firstMatch(value) == null) {
                      return "Invalid Tracking Code";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      label: const Text("Tracking ID"),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                ),
                const Expanded(child: SizedBox()),
                ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      Navigator.of(context).pop();

                      Navigator.of(context)
                          .push(PageRouteBuilder(pageBuilder: (a, c, s) {
                        return ProductHistory(cid: _controller.text);
                      }));
                    },
                    child: const Text("Continue"))
              ],
            ),
          ),
        ));
  }
}

class ProductHistory extends StatefulWidget {
  const ProductHistory({super.key, required this.cid});
  final String cid;

  @override
  State<ProductHistory> createState() => _ProductHistoryState();
}

class _ProductHistoryState extends State<ProductHistory> {
  ProductChain? productChain;
  bool fetchingData = true;

  fetchData() {
    DatabaseService().getData(widget.cid).then((value) {
      setState(() {
        productChain = ProductChain.fromJson(value!);
        fetchingData = false;
      });
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (fetchingData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return TreeViewPage(productChain: productChain!);
  }
}

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key, required this.productChain});
  final ProductChain productChain;

  @override
  State<TreeViewPage> createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  Widget endDrawer = const Drawer();

  void setEndDrawer(Widget newDrawer) {
    setState(() {
      endDrawer = newDrawer;
    });
  }

  @override
  void initState() {
    Node t = Node.Id(widget.productChain);
    graph.addNode(t);
    for (var element in widget.productChain.rawMaterials) {
      _buildGraph(graph, element, t);
    }
    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("History of ${widget.productChain.name}"),
        ),
        endDrawer: endDrawer,
        body: InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(50),
            scaleEnabled: false,
            trackpadScrollCausesScale: false,
            child: GraphView(
              animated: true,
              graph: graph,
              algorithm:
                  BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
              paint: Paint()
                ..color = Colors.green
                ..strokeWidth = 1
                ..style = PaintingStyle.stroke,
              builder: (Node node) {
                var a = node.key!.value;
                return GraphWidget(
                    context: context, a: a, setEndDrawer: setEndDrawer);
              },
            )));
  }

  Random r = Random();

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  void _buildGraph(Graph graph, ProductChain product, Node? parent) {
    var node = Node.Id(product);

    graph.addNode(node);

    if (parent != null) {
      graph.addEdge(parent, node);
    }

    for (var rawMaterial in product.rawMaterials) {
      _buildGraph(graph, rawMaterial, node);
    }
  }
}

class GraphWidget extends StatelessWidget {
  const GraphWidget(
      {super.key,
      required this.context,
      required this.a,
      required this.setEndDrawer});

  final BuildContext context;
  final ProductChain a;
  final Function setEndDrawer;

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(a.createdTs);
    String time =
        "${date.day}-${date.month}-${date.year} at ${date.hour.toString().length == 1 ? "0" : ""}${date.hour}:${date.minute.toString().length == 1 ? "0" : ""}${date.minute}";
    return InkWell(
      onTap: () {
        showModalBottomSheet(
            constraints: const BoxConstraints(maxHeight: 700, maxWidth: 1000),
            isDismissible: true,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return ProductDetails(product: a.toProduct());
            });
        return;
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  spreadRadius: 1),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              Text(
                a.desc,
                maxLines: 2,
              ),
              Text(time)
            ],
          )),
    );
  }
}
