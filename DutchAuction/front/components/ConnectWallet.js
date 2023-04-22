import { NetworkErrorMessage} from "./NetworkErrorMessage"

export function ConnectWallet({connectWallet, networkError, dismiss}){
    return (
        <>
            <div>
                {networkError && (
                    <NetworkErrorMessage 
                        message={networkError}
                        dismiss={dismiss}
                    />
                )}
            </div>

            <p>Connect your wallet</p>
            <button type="button" onClick={connectWallet}> 
                Connect Wallet!
            </button>


        
        </>
    )
}