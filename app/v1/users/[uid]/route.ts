import { getUser, updateUser } from '@/lib/db/queries'
import { NextResponse } from 'next/server'
import type { DatabaseUserInput } from '@/lib/db/types'

const DEFAULT_TENANT_ID = 'default'

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
    const result = await getUser(uid)

    if (!result.success) {
      return NextResponse.json(
        {
          success: false,
          error: result.error
        },
        { status: result.error?.code === 'USER_NOT_FOUND' ? 404 : 500 }
      )
    }

    return NextResponse.json({
      success: true,
      user: result.user
    })
  } catch (error) {
    console.error('Get user API error:', error)
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: error instanceof Error ? error.message : 'Failed to get user'
        }
      },
      { status: 500 }
    )
  }
}

export async function PUT(
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
    const body = await request.json()
    
    const { email, name, avatar, tenantId, isAdmin, phoneNumber, emailVerified, lastSignInAt, disabled } = body

    const userData: Partial<DatabaseUserInput> = {}

    if (email !== undefined) userData.email = email
    if (name !== undefined) userData.name = name
    if (avatar !== undefined) userData.avatar = avatar
    if (tenantId !== undefined) userData.tenantId = tenantId || DEFAULT_TENANT_ID
    if (isAdmin !== undefined) userData.isAdmin = isAdmin
    if (phoneNumber !== undefined) userData.phoneNumber = phoneNumber
    if (emailVerified !== undefined) userData.emailVerified = emailVerified
    if (lastSignInAt !== undefined) userData.lastSignInAt = new Date(lastSignInAt)
    if (disabled !== undefined) userData.disabled = disabled
    
    const result = await updateUser(uid, userData)

    if (!result.success) {
      return NextResponse.json(
        {
          success: false,
          error: result.error
        },
        { status: result.error?.code === 'USER_NOT_FOUND' ? 404 : 500 }
      )
    }

    return NextResponse.json({
      success: true,
      user: result.user
    })
  } catch (error) {
    console.error('Update user API error:', error)
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: error instanceof Error ? error.message : 'Failed to update user'
        }
      },
      { status: 500 }
    )
  }
}
