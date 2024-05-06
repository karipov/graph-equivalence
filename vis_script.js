function getColors() {
    // only use one Coloring (the first one)
    const coloring = instance.signature('Coloring').atoms()[0];
    const color_field = instance.field('color');

    const vertex_to_color_raw = coloring.join(color_field).tuples();

    const vertex_to_color = {};
    for (let i = 0; i < vertex_to_color_raw.length; i++) {
        const atoms = vertex_to_color_raw[i].atoms();
        vertex_to_color[atoms[0]] = atoms[1];
    }

    return vertex_to_color;
}

const vertices = instance.signature('Vertex').atoms();
const adjacent_field = instance.field('adjacent');
const colors = getColors();


const stage = new Stage();

stage.add(new TextBox({
    text: `${coloring.join(color_field)}`,
    coords: {x: 200, y: 100},
    color: 'black',
    fontSize: 16
}))

