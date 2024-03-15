// ** Hooks Import
import { useAuth } from 'src/hooks/useAuth'

const AuthGuard = props => {
  const { children } = props

  return <>{children}</>
}

export default AuthGuard
