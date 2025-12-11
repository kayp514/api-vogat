import { getUser, createUser } from '@/lib/db/queries'
import { NextResponse } from 'next/server'
import type { DatabaseUserInput } from '@/lib/db/types'

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
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

export async function POST(request: Request) {
  try {
    const body = await request.json()
    
    const { uid, email, name, avatar, tenantId, isAdmin, phoneNumber, emailVerified, CreatedAt, LastSignInAt } = body

    // Validate required fields
    if (!uid || !email || !tenantId) {
      return NextResponse.json(
        {
          success: false,
          error: {
            code: 'INVALID_INPUT',
            message: 'uid, email, and tenantId are required'
          }
        },
        { status: 400 }
      )
    }

    const userData: DatabaseUserInput = {
      uid,
      email,
      name: name || null,
      avatar: avatar || null,
      tenantId,
      isAdmin: isAdmin || false,
      phoneNumber: phoneNumber || null,
      emailVerified: emailVerified || false,
      CreatedAt: CreatedAt ? new Date(CreatedAt) : null,
      LastSignInAt: LastSignInAt ? new Date(LastSignInAt) : null,
    }

    const user = await createUser(userData)

    return NextResponse.json(
      {
        success: true,
        user
      },
      { status: 201 }
    )

  } catch (error) {
    console.error('Create user API error:', error)
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: error instanceof Error ? error.message : 'Failed to create user'
        }
      },
      { status: 500 }
    )
  }
}