import React from 'react';
import logo from './logo.svg';
import Navbar from './components/Navbar';
import Chat from './components/Chat';

function App() {

  const conversationContext = React.createContext([])

  return (
    <div className="h-screen flex bg-primary">
      <div className="basis-1/6">
        <Navbar></Navbar>
      </div>
      <div className="basis-5/6">
        <Chat></Chat>
      </div>
    </div>
  );
}

export default App;
