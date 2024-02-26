import { ConnectButton } from '@mysten/dapp-kit';

function App() {
  return (
    <div className="h-screen flex flex-col justify-center items-center">
      <h1 className="text-3xl font-bold text-red-400">
        Welcome to ComSui
      </h1>
      <ConnectButton />
    </div>
  );
}

export default App;
