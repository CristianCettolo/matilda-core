import React, { useContext } from 'react'
import { Card, List, Button } from 'antd'
import { MatildaContainer, MatildaPageRouter, MatildaContext, useMatildaRedirect, useMatildaRequest, useMatildaTranslator } from 'matilda_core/react_tools'
import './index.scss'

export default (props) => {
  return (
    <MatildaContainer matilda={props.matilda}>
      <MatildaPageRouter routes={[
        {
          component: <IndexView />,
          label: 'matilda_core.titles.users_list',
          internalPages: [{
            component: <ManageView />,
            label: 'matilda_core.titles.manage_user'
          }]
        },
        {
          component: <InvitationView />,
          label: 'matilda_core.titles.invite_user'
        },

      ]} />
    </MatildaContainer>
  )
}

/********************************************************************************************** */

function IndexView() {
  const { view: { key } } = useContext(MatildaContext)
  const { t } = useMatildaTranslator()

  //////////////////////////////////////////////////////////

  // ....

  //////////////////////////////////////////////////////////

  return (
    <div id={`${key}__listing`}>
      Pippo tutto il giorno e dopo smetto
    </div>
  )
}

/********************************************************************************************** */

function InvitationView() {
  const { view: { key } } = useContext(MatildaContext)
  const { t } = useMatildaTranslator()

  //////////////////////////////////////////////////////////

  // ....

  //////////////////////////////////////////////////////////

  return (
    <div id={`${key}__listing`}>
      
    </div>
  )
}

/********************************************************************************************** */

function ManageView() {
  const { view: { key } } = useContext(MatildaContext)
  const { t } = useMatildaTranslator()

  //////////////////////////////////////////////////////////

  // ....

  //////////////////////////////////////////////////////////

  return (
    <div id={`${key}__listing`}>
      
    </div>
  )
}