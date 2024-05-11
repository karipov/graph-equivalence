// ---------------------------------- GENERAL CONSTANTS -------------------------------------

const SCREEN_WIDTH = 500;
const SCREEN_HEIGHT = 600; 

const GRAPH_WIDTH = 500;
const GRAPH_HEIGHT = 500;

// -------------------------------- GRID RELATED CONSTANTS ----------------------------------

const GRID_X = GRAPH_WIDTH * 0.1 / 2;
const GRID_Y = GRAPH_HEIGHT * 0.1 / 2;
const GRID_CELL_WIDTH = (_) => (GRAPH_WIDTH * 0.9) / 2;
const GRID_CELL_HEIGHT = (node_len) => (GRAPH_HEIGHT * 0.9) / node_len;

// ------------------------------- BUTTON RELATED CONSTANTS ---------------------------------

const BUTTONS = ['COLOR', 'CONVERT'];
const BUTTON_WIDTH = SCREEN_WIDTH / BUTTONS.length * 0.9;
const BUTTON_HEIGHT = (SCREEN_HEIGHT - GRAPH_HEIGHT) * 0.7;
const BUTTON_SPACING = SCREEN_WIDTH / (BUTTONS.length + 1) * 0.1;
const BUTTON_Y = GRAPH_HEIGHT;
const BUTTON_XS = BUTTONS.map((_, idx) =>
    BUTTON_SPACING + idx * (BUTTON_WIDTH + BUTTON_SPACING)
);

const BUTTON_TEXT_Y = BUTTON_Y + BUTTON_HEIGHT / 2;
const BUTTON_TEXT_XS = BUTTON_XS.map(x => x + BUTTON_WIDTH / 2);

// -------------------------------- GRAPH RELATED CONSTANTS ---------------------------------

const NODE_RADIUS = 0.05 * (GRAPH_HEIGHT + GRAPH_WIDTH) / 2;
const EDGE_WIDTH = 0.01 * (GRAPH_HEIGHT + GRAPH_WIDTH) / 2;
const GRAPH_RADIUS = 0.9 * ((GRAPH_HEIGHT + GRAPH_WIDTH) / 4) - NODE_RADIUS;

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
        const neighbors = vertex.join(adjacent_field).tuples().map(
            vtx => vtx.atoms()[0].id()
        );

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

/**
 * Set the color of each node according to the coloring
 * @param {Array<Circle>} nodes Array of Circle objects
 * @param {Array<String>} node_colors Array of colors in hexadecimal format
 */
function color_nodes(nodes, node_colors) {
    nodes.forEach((node, idx) => {
        node.setColor(node_colors[idx]);
    });
}

// -------------------------------- GRAPH CREATION FUNCTIONS --------------------------------

/**
 * Calculates the coordinates of the center of the graph (not canvas as a whole)
 * @returns {Object} Object with x and y coordinates of the center of the screen
 */
function get_center() {
    return {x: GRAPH_WIDTH/2, y: GRAPH_HEIGHT/2}
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
            color: 'white',
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

/**
 * Create the buttons for the visualization
 * @param {Number} N Number of buttons
 * @param {Array<Function>} callbacks Functions to be called when the button is clicked
 * @returns {Array<Rectangle | TextBox>} Array of Rectangle and TextBox objects
 */
function create_buttons(N, callbacks) {
    let buttons = [];
    for (let i = 0; i < N; i++) {
        const text_box = new TextBox({
            text: BUTTONS[i],
            coords: { x: BUTTON_TEXT_XS[i], y: BUTTON_TEXT_Y},
            fontSize: BUTTON_WIDTH / 5.5,
            color: 'black',
            events: [ { event: 'click', callback: () => { 
                        callbacks[i]();
                        stage.render(svg, document);
                    } } ]
        });
        const box = new Rectangle({
            coords: { x: BUTTON_XS[i], y: BUTTON_Y},
            width: BUTTON_WIDTH,
            height: BUTTON_HEIGHT,
            color: 'grey',
        });
        buttons.push(box);
        buttons.push(text_box);
    }
    return buttons;
}

// ------------------------------- SCHEDULE CREATION FUNCTIONS ------------------------------

/**
 * Generate realistic time-slots in the format of HH(AM/PM) - HH(AM/PM)
 * @param {Number} N number of time slots
 * @returns {Array} Array of strings with the time slots
 */
function generate_time_slots(N) {
    const time_slots = [];
    for (let i = 0; i < N; i++) {
        const start_hour = i + 8;
        const end_hour = (i + 1) + 8;

        const start_am_pm = start_hour < 12 ? 'AM' : 'PM';
        const end_am_pm = end_hour < 12 ? 'AM' : 'PM';

        const start_hour_12 = start_hour % 12 === 0 ? 12 : start_hour % 12;
        const end_hour_12 = end_hour % 12 === 0 ? 12 : end_hour % 12;

        time_slots.push(`${start_hour_12}${start_am_pm} - ${end_hour_12}${end_am_pm}`);
    }
    return time_slots;
}

/**
 * Create the grid for the schedule visualization
 * @param {Array<String>} node_colors Array of colors in hexadecimal format
 * @returns {[Grid, Rectangle]} The grid object and the grid slots
 *         (Rectangles with the color and time-slot)
 */
function create_grid(node_colors) {
    let grid = new Grid({
        grid_location: { x: GRID_X, y: GRID_Y },
        cell_size: {
            x_size: GRID_CELL_WIDTH(node_colors.length),
            y_size: GRID_CELL_HEIGHT(node_colors.length) },
        grid_dimensions: { x_size: 2 , y_size: node_colors.length },
    });

    // add each course to the grid
    for (let i = 0; i < node_colors.length; i++) {
        grid.add({ x: 0, y: i }, new TextBox({
            text: `Course #${i}`,
                fontSize: GRID_CELL_HEIGHT(node_colors.length) / 2.5,
                color: 'black',
            }));
    }

    // add each color / time-slot to the grid
    let slots = generate_time_slots(get_how_many_colors());
    let node_slots = get_node_to_color().map(idx => slots[idx]);

    let grid_slots = [];
    for (let i = 0; i < node_colors.length; i++) {
        let slot = new Rectangle({
            width: GRID_CELL_WIDTH(node_colors.length),
            height: GRID_CELL_HEIGHT(node_colors.length),
            color: 'white',
            borderColor: 'black',
            label: node_slots[i],
            labelSize: GRID_CELL_HEIGHT(node_colors.length) / 2.5,
            labelColor: 'white',
        });
        grid.add({ x: 1, y: i }, slot);
        grid_slots.push(slot);
    }
   
    return [grid, grid_slots];
}

// --------------------------------- BUTTON STATE MACHINE -----------------------------------

/**
 * Toggles the color of the nodes and the grid slots
 * @param {Array<Circle>} nodes Array of Circle objects
 * @param {Array<String>} node_colors Array of colors in hexadecimal format
 * @param {Array<Rectangle>} grid_slots Array of Rectangle objects
 *        representing the grid slots
 */
let color_button_toggle = false;
function color_button(nodes, node_colors, grid_slots) {
    color_button_toggle = !color_button_toggle;
    if (color_button_toggle) {
        color_nodes(nodes, node_colors);
        grid_slots.forEach((slot, idx) => {
            slot.setColor(node_colors[idx]);
            slot.setLabelColor('black');
        })
    } else {
        color_nodes(nodes, Array(nodes.length).fill('white'));
        grid_slots.forEach(slot => {
            slot.setColor('white');
            slot.setLabelColor('white');
        })
    }
}

/**
 * Toggles between the graph and the grid
 * @param {Stage} stage D3FX Stage object
 * @param {Array<Object>} other_objects Array of graph-related objects
 * @param {Grid} grid Grid object
 */
let convert_button_toggle = false;
function convert_button(stage, other_objects, grid) {
    convert_button_toggle = !convert_button_toggle;
    if (convert_button_toggle) {
        other_objects.forEach(obj => stage.remove(obj));
        stage.add(grid);
    } else {
        other_objects.forEach(obj => stage.add(obj));
        stage.remove(grid);
    }
}


// ------------------------------------ VISUALIZATION ---------------------------------------

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

// generate grid
let [grid, grid_slots] = create_grid(node_colors);

// generate buttons
let buttons = create_buttons(BUTTONS.length,
    [() => color_button(nodes, node_colors, grid_slots),
    () => convert_button(stage, nodes.concat(edges), grid)]
);

// add all the objects to the initial render
nodes.concat(edges, buttons).forEach(obj => {
    stage.add(obj);
});

stage.render(svg, document);

// resize the SVG container to custom dimensions
const svgContainer = document.getElementById('svg-container');
svgContainer.getElementsByTagName('svg')[0].style.height = `${SCREEN_HEIGHT}px`;
svgContainer.getElementsByTagName('svg')[0].style.width = `${SCREEN_WIDTH}px`;

