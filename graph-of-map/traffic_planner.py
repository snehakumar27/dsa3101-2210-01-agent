import pandas as pd
import plotly.express as px
import dash
from dash import html
from dash import dcc
from dash.dependencies import Input, Output
from PIL import Image

map = Image.open("map.jpg")

traffic_lights_x = [0.65, 0.9, 0.6, 1.45, 1.1, 1.76]
traffic_lights_y = [1.5, 1.95, 2.3, 1.8, 2.85, 2.2]
traffic_light_crowds = [20, 27, 38, 52, 22, 58]
traffic_light_labels = ["A", "B", "C", "D", "E", "F"]
df = pd.DataFrame(list(zip(traffic_lights_x, traffic_lights_y, traffic_light_crowds, traffic_light_labels)), columns=["x", "y", "crowd", "labels"])

roads_x0 = [0.15, 0.6, 0.65, 0.92, 1.15, 0.65, 1.39, 1.55, 1.45, 0.65]
roads_x1 = [1.6, 1.4, 1.5, 1.45, 1.8, 1.1, 1.45, 1.8, 1.6, 0.65]
roads_y0 = [2.0, 2.3, 1.55, 2.54, 2.85, 2.25, 1.3, 1.7, 1.79, 1]
roads_y1 = [0.6, 1.3, 2.7, 1.85, 2.2, 2.85, 1.86, 2.2, 1.79, 1.5]
density = ["dash", "dash", "dot", "dot", "solid", "dot", "dash", "dot", "dash", "dash"]
df_roads = pd.DataFrame(list(zip(roads_x0, roads_x1, roads_y0, roads_y1, density)), columns=["x0", "x1", "y0", "y1", "density"])

def create_graph(lights_df, roads_df):
    fig=px.scatter(lights_df, x="x", y="y", size="crowd", hover_name="labels", range_x=[0,2], range_y=[0,3], width=800, height = 800)
    for i in range(len(roads_df)):
        fig.add_shape(type="line", x0=roads_df["x0"][i], y0=roads_df["y0"][i], x1=roads_df["x1"][i], y1=roads_df["y1"][i], 
        line=dict(
            color="Brown",
            width=5,
            dash=roads_df['density'][i],
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
        html.Div(
            children = [
                 dcc.Graph(id = "map", figure = create_graph(df, df_roads))
            ]
        )
    ]

)

if __name__ == '__main__':
    app.run_server(debug=True, port = 8055)