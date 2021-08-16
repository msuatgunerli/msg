# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %%
import numpy as np
from sklearn.preprocessing import scale, normalize


# %%
class PCA:

    def __init__(self, n_components):
        self.n_components = n_components
        self.components = None
        # self.mean = None

    def fit(self, X):

        '''# calculate the mean and mean center all columns
        self.mean = np.mean(X, axis = 0)
        X = X - self.mean'''

        # mean center the data and ensure unit variance
        X = scale(X)
        # construct the covariance matrix
        covar = np.cov(X.T)
        
        #calculate eigenvectors and the corresponding eigenvalues
        eigenvalues, eigenvectors = np.linalg.eig(covar)

        #reorder eigenvectors and eigenvalues
        eigenvectors = eigenvectors.T
        reorder = np.argsort(eigenvalues)[::-1]
        eigenvalues = eigenvalues[reorder]
        eigenvectors = eigenvectors[reorder]

        # use the first n eigenvalues and eigenvectors
        self.components = eigenvectors[0:self.n_components]

    def transform(self,X):
        #X = X-self.mean
        X = scale(X)
        return np.dot(X, self.components.T)


