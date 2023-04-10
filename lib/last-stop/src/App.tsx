import Navbar from './components/Navbar';
import Chat from './components/Chat';
import { Provider } from 'react-redux';
import { store } from './services/Store';

function App() {
  return (
    <div className="h-screen flex bg-primary">
      <Provider store={store}>
        <div className="basis-1/6">
          <Navbar/>
        </div>
        <div className="basis-5/6">
          <Chat/>
        </div>
      </Provider>
    </div>
  );
}

export default App;
