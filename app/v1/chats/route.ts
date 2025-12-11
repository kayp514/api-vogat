import { getUserChats, createNewChat } from '@/lib/db/queries'
import { NextResponse } from 'next/server'

const DEFAULT_TENANT_ID = 'default'

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const uid = searchParams.get('uid')
    const tenantId = searchParams.get('tenantId') || DEFAULT_TENANT_ID

    if (!uid) {
      return NextResponse.json(
        {
          success: false,
          error: {
            code: 'INVALID_INPUT',
            message: 'uid is required'
          }
        },
        { status: 400 }
      )
    }

    const result = await getUserChats(uid, tenantId)

    if (!result.success) {
      return NextResponse.json(
        {
          success: false,
          error: result.error
        },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      chats: result.chats
    })

  } catch (error) {
    console.error('Chats API error:', error)
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to fetch chats'
        }
      },
      { status: 500 }
    )
  }
}

export async function POST(request: Request) {
  try {
    const { uid, tenantId, recipientId, content } = await request.json()

    if (!uid) {
      return NextResponse.json(
        {
          success: false,
          error: {
            code: 'INVALID_INPUT',
            message: 'uid is required'
          }
        },
        { status: 400 }
      )
    }

    if (!recipientId || !content?.trim()) {
      return NextResponse.json(
        {
          success: false,
          error: {
            code: 'INVALID_INPUT',
            message: 'Recipient and message content are required'
          }
        },
        { status: 400 }
      )
    }

    const result = await createNewChat(
      uid,
      recipientId,
      tenantId || DEFAULT_TENANT_ID,
      content
    )

    if (!result.success) {
      return NextResponse.json(
        {
          success: false,
          error: result.error
        },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      chat: result.chat
    })

  } catch (error) {
    console.error('Error in Sending Message:', error)
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to send message'
        }
      },
      { status: 500 }
    )
  }
}