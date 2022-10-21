import pandas as pd
import plotly.express as px
import dash
from dash import html
from dash import dcc
from dash.dependencies import Input, Output
from PIL import Image

map = Image.open("map.jpg")
light_density = pd.read_csv("light_density.csv")
roads_density = pd.read_csv("road_density.csv")
test_data = pd.read_csv("test_data.csv")

traffic_lights_x = [0.65, 0.9, 0.6, 1.45, 1.1, 1.76]
traffic_lights_y = [1.5, 1.95, 2.3, 1.8, 2.85, 2.2]
#traffic_light_crowds = [20, 27, 38, 52, 22, 58]
traffic_light_labels = ["A", "B", "C", "D", "E", "F"]
lights_df = pd.DataFrame(list(zip(traffic_lights_x, traffic_lights_y, traffic_light_labels)), columns=["x", "y", "labels"])

roads_x0 = [0.15, 0.6, 0.65, 0.92, 1.15, 0.65, 1.39, 1.55, 1.45, 0.65]
roads_x1 = [1.6, 1.4, 1.5, 1.45, 1.8, 1.1, 1.45, 1.8, 1.6, 0.65]
roads_y0 = [2.0, 2.3, 1.55, 2.54, 2.85, 2.25, 1.3, 1.7, 1.79, 1]
roads_y1 = [0.6, 1.3, 2.7, 1.85, 2.2, 2.85, 1.86, 2.2, 1.79, 1.5]
density = ["dash", "dash", "dot", "dot", "solid", "dot", "dash", "dot", "dash", "dash"]
roads_df = pd.DataFrame(list(zip(roads_x0, roads_x1, roads_y0, roads_y1)), columns=["x0", "x1", "y0", "y1"])


#function to convert road density to line type
def density_converter(x):
    if x < 30:
        return "dot"
    elif x < 60:
        return "dash"
    else:
        return "solid"

#function to create graph
def create_graph(light_density, roads_density, time):
    lights_full = lights_df.copy(deep=True)
    lights_full["crowd"] = light_density[str(time)]

    roads_full = roads_df.copy(deep=True)
    roads_full["density"] = roads_density[str(time)]

    fig=px.scatter(lights_full, x="x", y="y", size="crowd", hover_name="labels", range_x=[0,2], range_y=[0,3], width=800, height = 800)
    for i in range(len(roads_full)):
        fig.add_shape(type="line", x0=roads_full["x0"][i], y0=roads_full["y0"][i], x1=roads_full["x1"][i], y1=roads_full["y1"][i], 
        line=dict(
            color="Brown",
            width=5,
            dash=density_converter(roads_full['density'][i])
            )
        )

    fig.update_layout(
                images= [dict(
                    source=map,
                    xref="x", yref="y",
                    x=0, y=3,
                    sizex=2, sizey=2.5,
                    xanchor="left",
                    yanchor="top",
                    sizing="stretch",
                    layer="below")])
    fig.update_traces(marker=dict(color = "pink"),
                  selector=dict(mode='markers'))
    
    return fig

app = dash.Dash()
app.layout = html.Div(
    children=[
        html.Div(
            children = [
                dcc.Slider(0, 24, 1,
                    value=0,
                    id='time-slider'
                )
            ]
        ),
        
        html.Div(children = [
            html.P('Number of Lanes:'),
            dcc.Input(id='lanes', type='number', min=1, max=4),
        ], style = {}),
        
        html.Div(
            className='selection',
            children=[
                html.Div(
                    children=[
                    html.Label("Ratio between the duration of green and red lights:",
                        style={'Align': 'center'}),
                    dcc.Dropdown(id="ratio", options=[{'label': time, 'value':time}
                        for time in ['0.5', '1','1.5','2']],
                                style={'width':'200px', 'margin':'0 auto','textAlign': 'center'},
                                value='0.5')
                    ]),
                html.Div(
                    children=[
                        html.Label("Time of the day:",
                            style={'Align': 'center'}),
                        dcc.Dropdown(id="time_period", options=["Morning", "Afternoon", "Night"],
                            style={'width':'200px', 'margin':'0 auto','textAlign': 'center'},
                            value='Morning'),
                    ]),  
                ], style={'margin': 'auto'}),
        
        html.Div(
            children = [
                 dcc.Graph(id = "map_graph", figure = create_graph(light_density, roads_density, 0))
            ]
        ),
        
    ]

)
@app.callback(
    Output(component_id="map_graph", component_property='figure'),
    Input(component_id='time-slider', component_property='value')
)
def update_plot(time):
    if time:
        map_graph = create_graph(light_density, roads_density, time)
    return map_graph

if __name__ == '__main__':
    app.run_server(debug=True, port = 8055)
