import { getUserWorkspaces } from '@/lib/db/queries'
import { NextResponse } from 'next/server'

export async function GET(
  request: Request,
  { params }: { params: Promise<{ uid: string }> }
) {
  const { uid } = await params

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

  try {
    const result = await getUserWorkspaces(uid)

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
      workspaces: result.workspaces
    })
  } catch (error) {
    console.error('Get user workspaces API error:', error)
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: error instanceof Error ? error.message : 'Failed to get user workspaces'
        }
      },
      { status: 500 }
    )
  }
}
