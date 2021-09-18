# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %%
from IPython import get_ipython

# %%
import matplotlib.pyplot as plt
import pandas as pd
from mpl_toolkits.mplot3d import Axes3D
import scipy as sp
import numpy as np
import seaborn as sns
from sklearn import datasets
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
get_ipython().run_line_magic('matplotlib', 'widget')
#from matplotlib.text import Annotation
#from mpl_toolkits.mplot3d.proj3d import proj_transform
#import scipy.interpolate
#from matplotlib import cm

#sns.set_style('darkgrid')  # set the grid style for the seaborn plots
pd.set_option('display.float_format', lambda x: '%.5f' %
              x)  # suppress scientific notation in pandas


# %%
def MSGPCA(X, n_components):
    Xvals = X.values
    Xvals = StandardScaler().fit_transform(Xvals)
    pca = PCA(n_components)
    PCs = pca.fit_transform(Xvals)

    pc1_loading_scores = pd.DataFrame(
        data=pca.components_[0], index=X.columns, columns=['PC1 Loading Score'])
    pc1_loading_scores.sort_values(
    by='PC1 Loading Score', ascending=False, inplace=True)

    df_PCs = pd.DataFrame(data=PCs, columns=['PC1'])
    print("Proportion of Variance Explained : ", pca.explained_variance_ratio_)
    return df_PCs, pc1_loading_scores


