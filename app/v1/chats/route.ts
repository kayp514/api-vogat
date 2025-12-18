import { getUserChats, createNewChat } from '@/lib/db/queries'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const workspaceId = searchParams.get('workspaceId')
    const uid = searchParams.get('uid')

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


    const result = await getUserChats(uid, workspaceId || undefined)

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
      chats: result.chats,
      workspaceId: workspaceId || null
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
    const { uid, tenantId, recipientId, content, workspaceId } = await request.json()

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
      workspaceId || '',
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
      chat: result.chat,
      workspaceId: workspaceId || null,
      roomId: result.roomId
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