import React from 'react';
import logo from '../assets/logo.png';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faRotateLeft } from '@fortawesome/free-solid-svg-icons';
import { faGithub } from '@fortawesome/free-brands-svg-icons';

function Navbar() {

  return (
      <div className="flex h-screen flex-col justify-between border-r bg-white">
        <div className="px-4 py-6">
          <div className='flex justify-center items-center h-20 object-fill bg-opacity-0 mb-2'>
            <img src={logo} alt='logo'/>
          </div>
          
          <nav aria-label="Main Nav" className="mt-6 pt-6 flex flex-col space-y-1">
            <a
              href="#"
              className="flex items-center gap-2 rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700"
            >
              <FontAwesomeIcon icon={faRotateLeft} />
              <span className="text-sm font-medium"> New conversation </span>
            </a>

            <a
              href="https://github.com/circulatedev/last-stop" 
              target="_blank"
              className="flex items-center gap-2 rounded-lg px-4 py-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700"
            >
              <FontAwesomeIcon icon={faGithub} />
              <span className="text-sm font-medium"> Last Stop </span>
            </a>

          </nav>
        </div>
      </div>
      
  );
}

export default Navbar;