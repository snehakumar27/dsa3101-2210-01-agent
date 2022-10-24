import pandas as pd
import plotly.express as px
import dash
from dash import html
from dash import dcc
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc
import plotly.graph_objects as go
from plotly.subplots import make_subplots

data = pd.read_excel("permsnewdata.xlsx", header=0)
data.head()


###TAB 1 GRAPHS


### TAB 2-1 GRAPHS
def create_plot_crowd():
    line1 = data[data['num_lanes'] ==1]
    line2 = data[data['num_lanes'] ==2]
    line3 = data[data['num_lanes'] ==3]
    line4 = data[data['num_lanes'] ==4]

    crowd_heat_df = data[["num_lanes", "light_interval", "avg_crowd_size"]]
    crowd_lanes = data[["num_lanes", "avg_crowd_size"]].groupby("num_lanes").mean()
    crowd_light_interval = data[["light_interval", "avg_crowd_size"]].groupby("light_interval").mean()
    crowd_light_interval1 = line1[["light_interval", "avg_crowd_size"]].groupby("light_interval").mean()
    crowd_light_interval2 = line2[["light_interval", "avg_crowd_size"]].groupby("light_interval").mean()
    crowd_light_interval3 = line3[["light_interval", "avg_crowd_size"]].groupby("light_interval").mean()
    crowd_light_interval4 = line4[["light_interval", "avg_crowd_size"]].groupby("light_interval").mean()
    #df = [crowd_light_interval1,crowd_light_interval2,crowd_light_interval3,crowd_light_interval4]
    #newdata =pd.concat(df)

    interval1 = data[data['light_interval'] ==0.5]
    interval2 = data[data['light_interval'] ==1.0]
    interval3 = data[data['light_interval'] ==1.5]
    interval4 = data[data['light_interval'] ==2.0]
    crowd_lanes1 = interval1[["num_lanes","light_interval", "avg_crowd_size"]].groupby("num_lanes").mean()
    crowd_lanes2 = interval2[["num_lanes","light_interval", "avg_crowd_size"]].groupby("num_lanes").mean()
    crowd_lanes3 = interval3[["num_lanes","light_interval", "avg_crowd_size"]].groupby("num_lanes").mean()
    crowd_lanes4 = interval4[["num_lanes","light_interval", "avg_crowd_size"]].groupby("num_lanes").mean()
    #df2 = [crowd_lanes1,crowd_lanes2,crowd_lanes3,crowd_lanes4]
    #newdata2 =pd.concat(df2)

    
    fig = make_subplots(
        rows=3, cols=1,
        vertical_spacing=0.15,
        subplot_titles=("no.of lanes VS average crowd size",
                        "traffic light interval VS average crowd size",
                        "Heatmap between traffic light interval and average crowd size"),
        row_heights=[0.6,0.6,0.95])
        

    fig.add_trace(
    go.Heatmap(x = crowd_heat_df["num_lanes"],
        y =  crowd_heat_df["light_interval"],
        z =  crowd_heat_df["avg_crowd_size"],
               colorbar=dict(y=0.16,len=.3)
        ),
    row=3, col=1,
    )

    #first graph with four lines
    trace_1 = go.Line(x = crowd_lanes1.index,
                      y = crowd_lanes1["avg_crowd_size"],
                      name = "light_interval = 0.5",
                      legendgroup='1')
    trace_2 = go.Line(x = crowd_lanes2.index,
                      y = crowd_lanes2["avg_crowd_size"],
                      name = "light_interval = 1.0",
                      #legendgroup='1'
                      )
    trace_3 = go.Line(x = crowd_lanes3.index,
                      y = crowd_lanes3["avg_crowd_size"],
                      name = "light_interval = 1.5",
                      #legendgroup='1'
                      )
    trace_4 = go.Line(x = crowd_lanes4.index,
                      y = crowd_lanes4["avg_crowd_size"],
                      name = "light_interval = 2.0",
                      #legendgroup='1'
                      )
    
    
    fig.add_trace(trace_1,
    row=1, col=1,
    )
    fig.add_trace(trace_2,
    row=1, col=1,
    )
    fig.add_trace(trace_3,
    row=1, col=1,
    )
    fig.add_trace(trace_4,
    row=1, col=1,
    )

    #second graph with four lines
    trace1 =go.Line(x = crowd_light_interval1.index,
        y = crowd_light_interval1["avg_crowd_size"],
                    name = "number of lanes = 1",
                    legendgroup='2'
        )
    
    trace2 =go.Line(x = crowd_light_interval2.index,
        y = crowd_light_interval2["avg_crowd_size"],
                    name = "number of lanes = 2",
                    #legendgroup='2'
        )

    trace3 =go.Line(x = crowd_light_interval3.index,
        y = crowd_light_interval3["avg_crowd_size"],
                    name = "number of lanes = 3",
                    #legendgroup='2'
        )

    trace4 =go.Line(x = crowd_light_interval4.index,
        y = crowd_light_interval4["avg_crowd_size"],
                    name = "number of lanes = 4",
                    #legendgroup='2'
        )
    
    fig.add_trace(trace1,
    row=2, col=1,
    )

    fig.add_trace(trace2,
    row=2, col=1,
    )

    fig.add_trace(trace3,
    row=2, col=1,
    )

    fig.add_trace(trace4,
    row=2, col=1,
    )
    

    
    
    fig.update_xaxes(title_text="Traffic light interval", row=2, col=1)
    fig.update_xaxes(title_text="Number of Lanes", row=1, col=1)
    fig.update_xaxes(title_text="Number of lines", row=3, col=1)

    fig.update_yaxes(title_text="Average Crowd Size", row=2, col=1)
    fig.update_yaxes(title_text="Average Crowd Size", row=1, col=1)
    fig.update_yaxes(title_text="Traffic light interval", row=3, col=1)
    fig.update_layout(
        height = 800,
        width = 800,
        #legend_tracegroupgap = 180,
        showlegend=True
    )


    return fig

### TAB 2-2 GRAPHS


### TAB 2-3 GRAPHS



app = dash.Dash(external_stylesheets=[dbc.themes.BOOTSTRAP, 'https://codepen.io/chriddyp/pen/bWLwgP.css'])

#### TAB 1 CONTENT
content1 = dbc.Row([
    dbc.Col([
        html.H3("Placeholder for inputs"),
        html.H3("Placeholder for outputs")
    ], width = 5),
    dbc.Col([
        html.H3("Placeholder for Graph"),
    ])
]
)

### TAB 2 CONTENT
content2 = dcc.Tabs(id="graph-tabs", children=[
            dcc.Tab([dcc.Graph(id = "graph_crowd", figure=create_plot_crowd())],label='Pedestrians'),
            dcc.Tab([dcc.Graph(id = "graph_crowd2", figure=create_plot_crowd())],label='Cars'),
            dcc.Tab(label='Compare'),
        ],  vertical=True, parent_style={'float': 'left'})



### OVERALL

## SIDEBAR

sidebar = html.Div([
    html.H6("Number of Cars"),
    dcc.Slider(id = "number-of-cars", min = 0, max = 50, step = 5, value=10, 
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Number of Pedestrians"),
    dcc.Slider(id = "number-of-pedestrians", min = 0, max = 50, step = 5, value=10, 
        tooltip={"placement": "bottom", "always_visible": True}),
    html.H6("Max patience"),
    dcc.Slider(id = "max-patience", min = 0, max = 1, step = 0.2, value=1, 
        tooltip={"placement": "bottom", "always_visible": True}),
])

### TABS

tabs = dbc.Tabs([
    dbc.Tab([
        content1
    ], label = "Tab 1"), 
    dbc.Tab([
        content2
    ], label = "Tab 2")
])


app.layout = html.Div(
    children=[
        html.H1("Title"),
        dbc.Row([ 
            dbc.Col([
                sidebar
            ], width = 2),
            dbc.Col([
                tabs
            ], width = 10)
        ])
    ],
    style={"margin-left": "20px", "margin-right": "20px", "margin-top": "15px"}
)


#####CALLBACKS


if __name__ == '__main__':
    app.run_server(debug=True, port = 8055)
