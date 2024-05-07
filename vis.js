// ----------------------------------- GENERAL CONSTANTS ------------------------------------

const SCREEN_WIDTH = 500;
const SCREEN_HEIGHT = 500; 

// -------------------------------- GRAPH RELATED CONSTANTS ---------------------------------

const NODE_RADIUS = 0.05 * (SCREEN_HEIGHT + SCREEN_WIDTH) / 2;
const EDGE_WIDTH = 0.01 * (SCREEN_HEIGHT + SCREEN_WIDTH) / 2;
const GRAPH_RADIUS = 0.9 * ((SCREEN_HEIGHT + SCREEN_WIDTH) / 4) - NODE_RADIUS;

// ------------------------- FORGE AND INSTANCE-RELATED FUNCTIONS ---------------------------

/**
 * Converts the name of an object in the forge to the index of the object
 * @param {string} forge_obj_str Name of the object in the forge
 * @returns {number} Index of the object in the forge
 */
function get_index(forge_obj_str) {
    return parseInt(forge_obj_str.slice(-1));
}

/**
 * @returns {number} Number of nodes in the instance
 */
function get_how_many_nodes() {
    return instance.signature('Vertex').atoms().length;
}

/**
 * @returns {number} Number of colors in the instance
 */
function get_how_many_colors() {
    return instance.signature('Color').atoms().length;
}

/**
 * Returns the colors of each vertex where the index of the array is the vertex ID
 * @returns {Array} Array of integers with the color assigned to each vertex
 */
function get_node_to_color() {
    // choose an arbitrary coloring (the first one)
    const coloring = instance.signature('Coloring').atoms()[0];
    const color_field = instance.field('color');

    const pairs = coloring.join(color_field).tuples();

    let colors = [];
    pairs.forEach(pair => {
        // get the last character of the color, e.g. Color1 => 1
        const color_name = pair.atoms()[1].id();
        colors.push(get_index(color_name));
    });

    return colors;
}

/**
 * Returns the adjacency list of the graph where the index of the array is the vertex ID
 * @returns {Map} Map where the key is the vertex ID and the value is an array
 *          with the neighbors' IDs
 */
function get_node_to_node() {
    const vertices = instance.signature('Vertex').atoms();
    const adjacent_field = instance.field('adjacent');

    let adjacency_map = new Map();
    vertices.forEach(vertex => {
        const neighbors = vertex.join(adjacent_field).tuples().map(vtx => vtx.atoms()[0].id());

        const neighbor_idxs = neighbors.map(neighbor => get_index(neighbor));
        const vertex_idx = get_index(vertex.id());

        adjacency_map.set(vertex_idx, neighbor_idxs);
    });

    return adjacency_map;
}

// ------------------------------------- COLOR FUNCTIONS ------------------------------------

/**
 * Converts HSV color to RGB color
 * @param {number} h Hue value
 * @param {number} s Saturation value
 * @param {number} v Value
 * @returns {String} string with r, g and b values in hexadecimal format
 * @source adapted from https://stackoverflow.com/a/17243070
 */
function hsv_to_rgb(h, s, v) {                              
  let f = (n, k = (n + h / 60 ) % 6) => (v - v * s * Math.max(Math.min(k, 4-k, 1), 0));
  let g = (n) => Math.round(f(n) * 255);  
  let colors = [g(5), g(3), g(1)];

  return `#${colors.map(c => c.toString(16).padStart(2, '0')).join('')}`;
}

/**
 * Generates N colors such that they are evenly distributed in the color wheel
 * @param {number} N Number of colors to generate
 * @returns {Array} Array of strings with the colors in RGB format
 */
function create_node_colors(N) {
    const colors = [];
    for (let i = 0; i < N; i++) {
        // Hue varies, while saturation and value are constant
        let hue = (360 * i / N) % 360;
        let saturation = 0.9; // High saturation for vivid colors
        let value = 0.9;      // High value for brightness

        colors.push(hsv_to_rgb(hue, saturation, value));
    }
    return colors;
}

// -------------------------------- GRAPH CREATION FUNCTIONS --------------------------------

/**
 * Calculates the coordinates of the center of the screen
 * @returns {Object} Object with x and y coordinates of the center of the screen
 */
function get_center() {
    return {x: SCREEN_WIDTH/2, y: SCREEN_HEIGHT/2}
}

/**
 * Gives the coordinates of some number of nodes arranged in a circle
 * @param {number} N Number of nodes
 * @param {number} radius Radius of the circle
 * @returns {Array} Array of objects with x and y coordinates
 */
function create_node_positions(N, radius) {
    const coordinates = [];
    let center = get_center();

    for (let i = 0; i < N; i++) {
        const angle = 2 * Math.PI * i / N;
        // convert polar coordinates to cartesian
        const x = radius * Math.cos(angle) + center.x;
        const y = radius * Math.sin(angle) + center.y;
        coordinates.push({x,  y});
    }

    return coordinates;
}

/**
 * Create the D3 nodes of the graph
 * @param {Array<Object>} node_positions List of x and y coordinates
 * @returns {Array<Circle>} Array of Circle objects
 */
function create_nodes(node_positions, node_colors) {
    let node_objects = [];
    node_positions.forEach((position, idx) => {
        const circle = new Circle({
            radius: NODE_RADIUS,
            center: position,
            borderWidth: EDGE_WIDTH,
            color: node_colors[idx],
            borderColor: 'black', 
            label: idx.toString(),
            labelSize: NODE_RADIUS,
        });
        node_objects.push(circle);
    });
    return node_objects;
}

/**
 * Create the D3 edges of the graph
 * @param {Array<Circle>} nodes Array of Circle objects
 * @param {Map} adjacency_map Map where the key is the vertex ID and the value is an array
 *         with the neighbors' IDs
 * @returns {Array<Line>} Array of Line objects
 */
function create_edges(nodes, adjacency_map) {
    let edges = [];
    adjacency_map.forEach((neighbors, idx) => {
        neighbors.forEach(neighbor => {
            const edge = new Edge({
                obj1: nodes[idx], obj2: nodes[neighbor],
                lineProps: { color: 'black', width: EDGE_WIDTH, },
            })
            edges.push(edge);
        });
    });

    return edges;
}

// -------------------------------------- VISUALIZATION -------------------------------------

const stage = new Stage();

// generate some colors and assign each node to its own color
let colors = create_node_colors(get_how_many_colors());
let node_colors = get_node_to_color().map(idx => colors[idx]);

// generate the positions of the nodes and the node objects
let node_positions = create_node_positions(get_how_many_nodes(), GRAPH_RADIUS);
let nodes = create_nodes(node_positions, node_colors);

// generate edges between the nodes
let adjacency_map = get_node_to_node();
let edges = create_edges(nodes, adjacency_map);

// add each node to the stage
nodes.forEach(node => {
    stage.add(node);
});

// add each edge to the stage
edges.forEach(edge => {
    stage.add(edge);
});

stage.render(svg, document);

// resize the SVG container to custom dimensions
const svgContainer = document.getElementById('svg-container');
svgContainer.getElementsByTagName('svg')[0].style.height = `${SCREEN_HEIGHT}px`;
svgContainer.getElementsByTagName('svg')[0].style.width = `${SCREEN_WIDTH}px`;

