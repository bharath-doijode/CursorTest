import React, {Suspense, lazy, ErrorInfo, Component} from 'react';
import {View, Text, StyleSheet, ActivityIndicator} from 'react-native';

interface MiniAppLoaderProps {
  appName: string;
  moduleName: string;
  fallbackComponent?: React.ReactNode;
}

interface ErrorBoundaryState {
  hasError: boolean;
  error?: Error;
}

class ErrorBoundary extends Component<
  {children: React.ReactNode; appName: string},
  ErrorBoundaryState
> {
  constructor(props: {children: React.ReactNode; appName: string}) {
    super(props);
    this.state = {hasError: false};
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return {hasError: true, error};
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error(`Error in ${this.props.appName}:`, error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <View style={styles.errorContainer}>
          <Text style={styles.errorTitle}>
            Failed to load {this.props.appName}
          </Text>
          <Text style={styles.errorMessage}>
            {this.state.error?.message || 'Unknown error occurred'}
          </Text>
          <Text style={styles.errorHint}>
            Make sure the mini app is running on the correct port
          </Text>
        </View>
      );
    }

    return this.props.children;
  }
}

export const MiniAppLoader: React.FC<MiniAppLoaderProps> = ({
  appName,
  moduleName,
  fallbackComponent,
}) => {
  // Dynamically import the mini app
  const LazyMiniApp = lazy(() => {
    try {
      // @ts-ignore - Module Federation dynamic import
      return import(/* webpackIgnore: true */ `${appName}/${moduleName}`);
    } catch (error) {
      console.error(`Failed to load ${appName}:`, error);
      throw error;
    }
  });

  const LoadingFallback = () => (
    <View style={styles.loadingContainer}>
      {fallbackComponent || (
        <>
          <ActivityIndicator size="large" color="#007AFF" />
          <Text style={styles.loadingText}>Loading {appName}...</Text>
        </>
      )}
    </View>
  );

  return (
    <ErrorBoundary appName={appName}>
      <Suspense fallback={<LoadingFallback />}>
        <LazyMiniApp />
      </Suspense>
    </ErrorBoundary>
  );
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5F5F5',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666666',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFF5F5',
    padding: 20,
  },
  errorTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#D32F2F',
    marginBottom: 8,
    textAlign: 'center',
  },
  errorMessage: {
    fontSize: 14,
    color: '#666666',
    marginBottom: 12,
    textAlign: 'center',
  },
  errorHint: {
    fontSize: 12,
    color: '#999999',
    textAlign: 'center',
    fontStyle: 'italic',
  },
});