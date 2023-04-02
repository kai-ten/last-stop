import React from 'react';
import logo from './logo.svg';
import Navbar from './components/Navbar';
import Chat from './components/Chat';

function App() {
  return (
    <div className="flex flex-row bg-primary">
      <div className="basis-1/6">
        <Navbar></Navbar>
      </div>
      <div className='basis-1/6'></div>
      <div className="basis-2/3">
        <Chat></Chat>
      </div>
      <div className='basis-1/6'></div>
    </div>
  );
}

export default App;
